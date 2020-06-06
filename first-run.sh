#!/bin/bash
set -x

# Setup env
MARIAN_INSTALLED_DIR=$(realpath ../env)

export PATH="$MARIAN_INSTALLED_DIR/bin:$PATH".
export LD_LIBRARY_PATH="$MARIAN_INSTALLED_DIR/lib:$LD_LIBRARY_PATH".

DATA_DIR="../data"
VOCABS_DIR=$DATA_DIR/vocabs
VOCAB_SIZE=8000

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


marian \
    --model pib.en-hi.npz   \
    --train-sets $DATA_DIR/pib/en-hi/train.{en,hi} \
    --valid-sets $DATA_DIR/mkb/en-hi/mkb.{en,hi} \
    --vocabs $VOCABS_DIR/pib_en.spm $VOCABS_DIR/pib_hi.spm \
    --dim-vocabs 8000 8000 \
    --devices 1 2 3     \
    --workspace=10000 --mini-batch-fit
