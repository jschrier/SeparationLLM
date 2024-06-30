#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory@ NotebookDirectory[];
<<"../src/data_formatting.wl"

With[
(* data for nitrate is in the second sheet of the XLSX file *)
(* define data inclusion criteria *)
	{data = Import["../data/Monoamide_Literature_Review.xlsx",
				"Dataset", "SkipLines" -> 1, HeaderLines -> 1][[2]],
	 inclusionCriteria = Select[singleMetalQ[#] && singleExtractantQ[#] && numericDistributionCoeffQ[#] &]		
	},
(* export as JSON text after casting to an association *)
	Export["../data/monoamide_text.json", 
		Normal@ Map[formatRow]@ inclusionCriteria@ data,
		"Compact"->2] 
]

