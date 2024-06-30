# SeparationLLM

 Language-interfaced fine-tuning for f-element separation demonstration.

# Data

 Source data was collected by L. Augustine in `data/Monoamide_Literature_Review.xlsx`.  
 
 This is reprocessed into sentence format: *"0.5 M of CCCCCCN(CCCCCC)C(=O)CCCCC in toluene is used to extract 50 mM Th(IV) from an aqueous solution of 4 M HNO3 and 4 M nitrate at 20 C. The contact time is 10 min and the radiolytic dosage is 0 kGy"*

 System prompt: *You are an expert liquid-liquid extraction chemist. Use the provided experiment description to predict the extraction selectivity. Return only VL, L, U, M, H.*

 All quantities are cast down to 1 significant figure 

 The task is to predict the distribution coefficient:
 - (Very Low: VL) D <= 0.01  (about 10%)
 - (Low: L) D <= 0.3 (about 25%)
 - (Unselective: U)  0.3 < D < 3 (about 35%)
 - (Moderate: M)   D < 10 (about 22%)
 - (High: H)   D >= 10 (about 8%)

(These divisions are somewhat arbitrary. The labels are each a single token in common tokenizers, and having only 5 labels lets us return all log-probs for the responses, which is conevenient )


# Models tested

- Fine-tuned `llama-3-8b`, `mistral-7b`, and `gpt-3-turbo-0125` using [OpenPipe](http://openpipe.ai); you can't set hyperparameters, so they're the defaults...

- Trained on a single random 80/20% train/test split

- We take the highest probability outcome (T=0) as the output, but also retrieve log-probs of all the possibilities (a nice trick we've used before!) So we can read out the presumed probabilities for each class.

# Preliminary results

- See `results/summary.json`:  Clear winner is GPT-3.5 (65% top-1 accuracy) compared to the other models (~ 41%), evaluated on 501 test items.  All are better than "guess the majority" class.
- Mistral-7b is not so good at following instructions, and usually added a space and wrote `VL` as `V`, so we added a few manual fixes for this.

# Ideas for future work:

- Try augmenting the dataset by generating randomized SMILES implementations (this might help for extrapolation to new organics)

- Investigate other performance measures:
    - Top-2 accuracy
    - Hold-one-ligand-out cross validation

- Test [other fine-tune platforms and strategies](https://jschrier.github.io/blog/2024/06/29/LLM-Finetuning-Notes.html) 
- Prompt engineering