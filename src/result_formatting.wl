(* ::Package:: *)

extractProbabilities[response_Association] := With[
  {topLogprobs = response[["choices", 1, "logprobs", "content", 1, "top_logprobs"]]},
  Map[Exp, AssociationThread @@ Transpose @ Lookup[{"token", "logprob"}] @ topLogprobs]]

keyWithLargestValue[x_Association] := First @ Keys @ TakeLargest[1] @ x

(* Mistral-7B fine tune has a tendency to include leading/trailing blanks *)
stripSpacesFromKeys[x_Association]:= KeyMap[StringTrim]@ x

(* Mistral-7B tends to respond "V" instead of "VL"*)
replaceV[x_Association]:=KeyMap[Replace["V"->"VL"]]@ x

evaluatePrediction[example_Association, config_LLMConfiguration] := With[
	{answer = Query["messages", 3, "content"] @ example, 
	response = replaceV@ stripSpacesFromKeys@ extractProbabilities @ OpenPipeExecute[#, config]& @ Query["messages", 1;;2] @ example},
    With[
     {predicted = keyWithLargestValue @ response},
     <|"correctQ" -> StringMatchQ[predicted, answer, IgnoreCase -> True], 
     "prediction" -> predicted,
     "answer" -> answer, 
     "output" -> ExportString[response, "JSON", "Compact" -> True], 
     "p(VL)" -> Lookup[response, "VL",0]+Lookup[response, "V",0],
     "p(L)" -> Lookup[response, "L", 0], 
     "p(U)" -> Lookup[response, "U", 0], 
     "p(M)" -> Lookup[response, "M", 0], 
     "p(H)" -> Lookup[response, "H", 0]|>]]
     
 


summarize[f_?FileExistsQ]:= With[
	{d = Import[f, "RawJSON"]},
	With[
		{measurements = ClassifierMeasurements[
			Query[All, "prediction"]@d, 
			Query[All, "answer"]@d]},
		<|"dataset" -> f,
		"accuracy" -> measurements["Accuracy"],
		"confusionMatrix"->measurements["ConfusionMatrix"],
		"n_correct" -> Total@ Boole@ Query[All, "correctQ"]@ d,
		"n_test" -> Query[Length]@ d|>]]
