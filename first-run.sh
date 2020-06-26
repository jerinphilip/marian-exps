#!/bin/bash
set -x

# Setup env
MARIAN_INSTALLED_DIR=$(realpath ../env)

export PATH="$MARIAN_INSTALLED_DIR/bin:$PATH".
export LD_LIBRARY_PATH="$MARIAN_INSTALLED_DIR/lib:$LD_LIBRARY_PATH".

DATA_DIR="../data"
VOCABS_DIR=$DATA_DIR/vocabs
VOCAB_SIZE=8000
SAVE_DIR="saves"
LOGS_DIR="logs"

mkdir -p $SAVE_DIR $LOGS_DIR

SRC='hi'
TGT='en'

LOGFILE="${LOGS_DIR}/$(date +'%Y-%m-%dT%H-%M-%S').log"

function create_vocabs {
    mkdir -p $VOCABS_DIR
    spm_train --input=$DATA_DIR/pib/en-hi/train.en\
        --model_prefix=$VOCABS_DIR/pib_en \
        --vocab_size=$VOCAB_SIZE

    spm_train --input=$DATA_DIR/pib/en-hi/train.hi\
        --model_prefix=$VOCABS_DIR/pib_hi \
        --vocab_size=$VOCAB_SIZE

    mv $VOCABS_DIR/pib_en.{model,spm}
    mv $VOCABS_DIR/pib_hi.{model,spm}
}

COMMON_ARGS=(
    --vocabs $VOCABS_DIR/pib_{hi,en}.spm 
    --dim-vocabs 8000 8000 
    --devices 1 2 3     
    --workspace=10000 
    --layer-normalization
)

TRAIN_ARGS=(
    --model "$SAVE_DIR/pib.hi-en.npz"
    --type transformer
    --save-freq 500u --valid-freq 500u 
    --train-sets $DATA_DIR/pib/en-hi/train.{hi,en} 
    --valid-sets $DATA_DIR/mkb/en-hi/mkb.{hi,en} 
    --valid-metrics cross-entropy perplexity bleu-detok
    --mini-batch-fit 
    --log $LOGFILE
)

DECODER_ARGS=(
    -m "$SAVE_DIR/pib.en-hi.npz"
    --quiet-translation
)


# Train
function train {
    marian \
        "${COMMON_ARGS[@]}" \
        "${TRAIN_ARGS[@]}"
}

train
# cat ${DATA_DIR}/mkb/en-hi/mkb.en | marian-decoder "${COMMON_ARGS[@]}" "${DECODER_ARGS[@]}"
