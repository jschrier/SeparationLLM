#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory@NotebookDirectory[];
<<"../src/finetuning.wl"
<<"../src/openpipe.wl"
<<"../src/result_formatting.wl"

test = importJSONL["../data/leave_one_out_test.jsonl"];


(* evaluate Llama-3-8B fine tune *)
config = LLMConfiguration[
 <|"Model" -> "openpipe:loo-llama3-8b",
  "Temperature" -> 10^-6,
  "LogProbs" -> 5 |>];
results = Map[ evaluatePrediction[#, config ]&, test];
Export["../results/test_loo_llama3-8b.json", %];

config = LLMConfiguration[
 <|"Model"-> "openpipe:loo-aug-llama3-8b",
  "Temperature"->10^-6,
  "LogProbs"->5|>];
results = Map[ evaluatePrediction[#, config ]&, test];
Export["../results/test_loo_aug_llama3-8b.json", %];


(* evaluate Llama-3-8B model trained on randomized-order augmented SMILES *)
config = LLMConfiguration[
 <|"Model"-> "openpipe:loo-aug-rand-llama3",
  "Temperature"->10^-6,
  "LogProbs"->5|>];
results = Map[ evaluatePrediction[#, config ]&, test];
Export["../results/test_loo_aug_rand_llama3-8b.json", %];



(* evaluate gpt-3-turbo-0125 fine tune *)
config = LLMConfiguration[
 <|"Model"-> "openpipe:loo-gpt35",
  "Temperature"->10^-6,
  "LogProbs"->5|>];
results = Map[ evaluatePrediction[#, config ]&, test];
Export["../results/test_loo_gpt35.json", %];

(* evaluate gpt-3-turbo-0125 fine tune *)
config = LLMConfiguration[
 <|"Model"-> "openpipe:loo-aug-gpt35",
  "Temperature"->10^-6,
  "LogProbs"->5|>];
 
results = Map[ evaluatePrediction[#, config ]&, test];
Export["../results/test_loo_aug_gpt35.json", %];


(* evaluate gpt-4o-mini fine tune *)
config = LLMConfiguration[
 <|"Model"-> "openpipe:loo-gpt4omini",
  "Temperature"->10^-6,
  "LogProbs"->5|>];
results = Map[ evaluatePrediction[#, config ]&, test];
Export["../results/test_loo_gpt40mini.json", %];

(* evaluate gpt-3-turbo-0125 fine tune *)
config = LLMConfiguration[
 <|"Model"-> "openpipe:loo-aug-rand-gpt4omini",
  "Temperature"->10^-6,
  "LogProbs"->5|>];
 
results = Map[ evaluatePrediction[#, config ]&, test];
Export["../results/test_loo_aug_rand_gpt40mini.json", %];


(* summarize results *)
Export["../results/summary.json", #, "Compact"->2]&@
	FileSystemMap[summarize, "../results/", FileNameForms->"test_*.json"];
	
