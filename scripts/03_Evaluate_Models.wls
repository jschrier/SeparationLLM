#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory@NotebookDirectory[];
<<"../src/finetuning.wl"
<<"../src/openpipe.wl"
<<"../src/result_formatting.wl"

test = importJSONL["../data/test.jsonl"];


(* evaluate Llama-3-8B fine tune *)
config = LLMConfiguration[
 <|"Model"-> "openpipe:monoamide-llama3-8b",
  "Temperature"->10^-6,
  "LogProbs"->5|>];

results = Map[ evaluatePrediction[#, config ]&, test];
Export["../results/test_llama3-8b.json", %];


(* evaluate Llama-3-7B fine tune *)
config = LLMConfiguration[
 <|"Model"-> "openpipe:monoamide-llama3-70b",
  "Temperature"->10^-6,
  "LogProbs"->5|>];

results = Map[ evaluatePrediction[#, config ]&, test];
Export["../results/test_llama3-70b.json", %];


(* evaluate Mistral-7B fine tune *)
(* observation: mistral tends to repond with trailing/leading blanks *)
(* observation: mistral tends to repond "V" instead of "VL" *)
config = LLMConfiguration[
 <|"Model"-> "openpipe:monoxide-mistral7b",
  "Temperature"->10^-6,
  "LogProbs"->5|>];
 
results = Map[ evaluatePrediction[#, config ]&, test];
Export["../results/test_mistral7b.json", %];


(* evaluate Mistral-8x7B instruct fine tune *)
config = LLMConfiguration[
 <|"Model"-> "openpipe:monoamide-mistral8x7b",
  "Temperature"->10^-6,
  "LogProbs"->5|>];
 
results = Map[ evaluatePrediction[#, config ]&, test];
Export["../results/test_mistral8x7b.json", %];


(* evaluate gpt-3-turbo-0125 fine tune *)
config = LLMConfiguration[
 <|"Model"-> "openpipe:monoamide-gpt35",
  "Temperature"->10^-6,
  "LogProbs"->5|>];
 
results = Map[ evaluatePrediction[#, config ]&, test];
Export["../results/test_gpt35.json", %];


(* summarize results *)
Export["../results/summary.json", #, "Compact"->2]&@
	FileSystemMap[summarize, "../results/", FileNameForms->"test_*.json"];
	
