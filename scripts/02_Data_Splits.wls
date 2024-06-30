#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory@ NotebookDirectory[];
<<"../src/finetuning.wl"

system = "You are an expert liquid-liquid extraction chemist.
Use the provided experiment description to predict the extraction selectivity.
Return only VL, L, U, M, H.";

data = Import["../data/monoamide_text.json", "RawJSON"];

data = Map[formatChatML[system, #]&]@ Lookup[{"input", "output"}]@ data;

SeedRandom[2024];
{train, test} = ResourceFunction["TrainTestSplit"]@ data;
{train, validate} = ResourceFunction["TrainTestSplit"]@ train;

exportChatML["../data/train.jsonl", train]
exportChatML["../data/validate.jsonl", validate]
exportChatML["../data/test.jsonl", test]

(* Openpipe uses an extension of ChatML*)
exportOpenPipeChatML["../data/openpipe.jsonl", Join[train, validate], test]



