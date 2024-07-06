#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory@ NotebookDirectory[];
<<"../src/data_formatting.wl"
<<"../src/finetuning.wl"

d = Import["../data/monoamide_text.json", "RawJSON"];


(* select a single example, with balance of outcomes as a test case*)

summarize[inchi_String][d_] := Counts@ Query[Select[#["ligand_inchikey"]==inchi&],  "output"]@ d

example = "PTNKBMIGCUULJJ-UHFFFAOYSA-N";
summarize[example]@ d
Total[%]


leaveExtractantOut[inchi_String][d_]:= With[
	{train = Query[Select[#["ligand_inchikey"] != inchi &]],
	test = Query[Select[#["ligand_inchikey"] == inchi &]]},
	{train[d], test[d]}]
	
{train, test} = leaveExtractantOut[example]@ d;
Length/@%


system = "You are an expert liquid-liquid extraction chemist.
Use the provided experiment description to predict the extraction selectivity.
Return only VL, L, U, M, H.";

tr  = Map[formatChatML[system, #]&]@ Lookup[{"input", "output"}]@ train;
te = Map[formatChatML[system, #]&]@ Lookup[{"input", "output"}]@ test;


exportOpenPipeChatML["../data/leave_one_out_openpipe.jsonl", tr, te]
exportChatML["../data/leave_one_out_test.jsonl", te]


(* try augmenting SMILES *)


augmentSMILES[row_, n_:5] := With[
	{notionalSMILES = row["ligand_smiles"],
	newSMILES = randomizeSMILES[row["ligand_smiles"], n]},
	<| "input" -> StringReplace[row["input"], notionalSMILES-> #],
	"output" -> row["output"]|> &/@ newSMILES]


augTr = Map[formatChatML[system, #]&]@ Lookup[{"input", "output"}]@ Flatten@ Map[augmentSMILES]@ train;



exportOpenPipeChatML["../data/leave_one_out_augmented_openpipe.jsonl", augTr, te]


(* other ideas:  augment the test data too... and use this to do uncertainty quantification of predictions *)
