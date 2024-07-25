#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory@ NotebookDirectory[];
r = Import["../results/summary.json"];


(* visualize random train/test split results *)
BarChart[
	{Labeled[35,"Guess majority", After],
	 Labeled[100*#,"GPT-3.5", Right]&@ Query["test_gpt35.json","accuracy"]@ r ,
	 Labeled[100*#,"GPT-4o-mini", Right]&@ Query["test_gpt40mini.json","accuracy"]@ r,
	 Labeled[100*#,"Llama-3-70B", After]&@ Query["test_llama3-70b.json","accuracy"]@r , 
	 Labeled[100*#, "Llama-3-8B", After]&@ Query["test_llama3-8b.json","accuracy"]@r,
	 Labeled[100*#, "Mistral-7B", After]&@ Query["test_mistral7b.json","accuracy"]@r,
	 Labeled[100*#, "Mistral-8x7B", After]&@ Query["test_mistral8x7b.json","accuracy"]@r},
	BarOrigin->Left,
	ChartStyle->{LightGray, LightOrange, Orange, Blue, LightBlue, Pink, LightPink},
	Frame->True, FrameLabel->"% Accuracy"]

Export["../figures/random_split_prelim.jpg", %]


(* visualize leave-one-extractant-out results *) 
BarChart[
	{Labeled[24.47, "Guess majority (U)", After],
	 Labeled[100*#, "GPT-3.5 (no augmentation)", Right]&@ Query["test_loo_gpt35.json", "accuracy"]@ r,
	 Labeled[100*#, "GPT-3.5 (5x SMILES aug)", Right]&@ Query["test_loo_aug_gpt35.json", "accuracy"]@ r,
	 Labeled[100*#, "GPT-4o-mini (no augmentation)", Right]&@ Query["test_loo_gpt40mini.json", "accuracy"]@ r,
	 Labeled[100*#, "GPT-4o-mini (aug+rand)", Right]&@ Query["test_loo_aug_rand_gpt40mini.json", "accuracy"]@ r,
	 Labeled[100*#,"Llama-3-8B (no augmentation)", After]&@ Query["test_loo_llama3-8b.json", "accuracy"]@ r ,
	 Labeled[100*#,"Llama-3-8B (5x SMILES aug)", After]&@ Query["test_loo_aug_llama3-8b.json", "accuracy"]@ r, 
	 Labeled[100*#, "Llama-3-8B (aug+rand)", After]&@ Query["test_loo_aug_rand_llama3-8b.json", "accuracy"]@ r },
	BarOrigin->Left,
	ChartStyle->{LightGray, LightOrange, LightOrange, Orange, Orange, LightBlue, LightBlue, LightBlue},
	Frame->True, FrameLabel->"% Accuracy"]
	
Export["../figures/loo_prelim.jpg", %]


(* compare prediction entropy *)

extractProbabilities = Query[All, {"p(VL)", "p(L)", "p(U)", "p(M)", "p(H)"}];
entropy[p_List] := -Total[ p*Log[p+10^-10]]

four = entropy/@ extractProbabilities@ Import["../results/test_gpt40mini.json"];
three =  entropy/@ extractProbabilities@ Import["../results/test_gpt35.json"];

PairedHistogram[three, four, 
	ChartLegends -> Placed[{{"GPT-3.5","GPT-4o-mini"}}, {Right, Top}],
	ChartStyle -> {{LightBlue, Blue}}]
	
Export["../figures/prediction_entropy_prelim.jpg", %]

four = entropy/@ extractProbabilities@ Import["../results/test_loo_gpt40mini.json"];
three =  entropy/@ extractProbabilities@ Import["../results/test_loo_gpt35.json"];

PairedHistogram[three, four, 
	ChartLegends -> Placed[{{"GPT-3.5","GPT-4o-mini"}}, {Right, Top}],
	ChartStyle -> {{LightBlue, Blue}}]



(* redo plot as perplexity *)

(* Limit[x^-x,x->0] == 1 *)
perplexity[p_List] := Product[ If[px==0, 1, px^-px], {px, p}]

four = perplexity/@ extractProbabilities@ Import["../results/test_gpt40mini.json"];
three =  perplexity/@ extractProbabilities@ Import["../results/test_gpt35.json"];

PairedHistogram[three, four, 
	ChartLegends -> Placed[{{"GPT-3.5", "GPT-4o-mini"}}, {Right, Top}],
	ChartStyle -> {{LightBlue, Blue}}]
	
Export["../figures/prediction_perplexity_prelim.jpg", %]


 (* roughly speaking, the perplexity of the random train/test split data is 4.39, 
    so both are meaningfully better *)
 
 perplexity@{0.1,0.25,0.35,0.22,0.08}
 
