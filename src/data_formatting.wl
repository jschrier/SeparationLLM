(* ::Package:: *)

(* select rows based on the number of species present *)
singleExtractantQ[row_] := EqualTo[1.]@ row["No. of Extractants"]
			
singleMetalQ[row_] := EqualTo[1.]@ row["# of Metals"]

numericDistributionCoeffQ[row_] := NumericQ@ row["Distribution Coefficient"]



(* quantity formatting rules *)

format[x_String, "M"] := "unknown concentration"
format[x_String, "mM"] := "trace" (* unreported metal concentrations are tracers *)
format[x_String, _] := "unknown"
format[x_?NumericQ, unit_String] := StringTemplate["`` ``"][SetPrecision[x, 1], unit]

formatContactTime[x_String] := "unknown"
formatContactTime[x_] := format[x, "min"] /; x >= 1
formatContactTime[x_] := "<1 min" /; x < 1

formatTemperature[x_String] := "about 20 C"
formatTemperature[x_?NumericQ] := format[x, "C"]

formatRadiolyticDosage[x_String] := "unknown"
formatRadiolyticDosage[x_] := "0 kGy" /; x == 0.0
formatRadiolyticDosage[x_] := "<250 kGy" /; x <= 250
formatRadiolyticDosage[x_] := ">250 kGy" /; x > 250


(* augment structures by scrambling the SMILES input
	https://resources.wolframcloud.com/FunctionRepository/resources/RandomSmilesString/ *)

randomizeSMILES[x_String, n_:1] := ResourceFunction["RandomSmilesString"][x, n]


(* convert a database row into a string description of the experiment *)
	
formatInput[row_Dataset]:= formatInput @ Normal @ row

(* TODO: There is also a COMMENT column in the spreadsheet, and we could think about how to include this *)

formatInput[row_Association] :=
  StringReplace[x:NumberString ~~ ". " :> x <> " "] @ 
  StringTemplate[
    "<*format[TemplateSlot[\"Extractant Concentration (M)\"], \"M\"]*> of `SMILES` in `Solvent` is used to extract <*format[TemplateSlot[\"Metal Concentration (mM)\"], \"mM\"]*> `Metal Identity` from an aqueous solution of <*format[TemplateSlot[\"Acid Concentration (M)\"], \"M\"]*> `Acid Type` and <*format[TemplateSlot[\"Nitrate Concentration (M)\"], \"M\"]*> nitrate at <*formatTemperature[TemplateSlot[\"Temperature (C)\"]]*>. The contact time is <*formatContactTime[TemplateSlot[\"Contact Time (min)\"]]*> and the radiolytic dosage is <*formatRadiolyticDosage[TemplateSlot[\"Radiolytic Dosage (kGy)\"]]*>."
    ] @ row

(* 
categorize distribution coefficients selectivites into Very-Low, Low, Unspecific, Modest, and High 
note that these abbreviations are just a single token, which facilitates log-prob extraction
*)

formatOutput[row_Dataset] := formatOutput @ row["Distribution Coefficient"]
formatOutput[row_Association] := formatOutput @ row["Distribution Coefficient"]
formatOutput[x_?NumericQ] := Which[
    x <= 0.01, "VL",
    x <= 0.3, "L",
    0.3 < x < 3, "U",
    x < 10,"M",
    x >= 10,"H"]


(* convert the row into a dictionary of text inputs and outputs; leave ligand key for cross-val *)

formatRow[row_] := <|
	"ligand_smiles" -> row["SMILES"], 
	"ligand_inchikey" -> Molecule[row["SMILES"]]["InChIKey"][[2]],
	"D" -> row["Distribution Coefficient"],
	"DOI" -> row["DOI"],
	"input" -> formatInput[row], 
	"output" -> formatOutput[row]|>
