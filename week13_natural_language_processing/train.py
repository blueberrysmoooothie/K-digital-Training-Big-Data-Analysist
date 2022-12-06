from webtoon_dataset import WebtoonDataset
from webtoon_model import DescriptionClassifier
from webtoon_dataloader import *

import torch
import torch.optim as optim
from argparse import Namespace
import pandas as pd
import numpy as np
import string
import re

# 데이터 정제
def preprocess_text(text):
    text = re.sub(r'([.,!?~])',r' \1', text)
    text = re.sub(r'[0-9.,!?~]+',r' ', text)
#     text = re.sub(r'')
    return text


args = Namespace(
    # 경로 정보
    frequency_cutoff=25,
    model_state_file='./model.pth',
    webtoon_csv='./data/naver.csv',
    save_dir='./model_storage/ch3/yelp/',
    vectorizer_file='vectorizer.json',

    # 모델 하이퍼 파라미터

    # 모델 훈련 하이퍼 파라미터
    batch_size=128,
    early_stopoping_criteria=5,
    learning_rate=0.001,
    num_epochs=100,
    seed=493
)

def  make_train_state(args):
    return{'epoch_index': 0,
           'train_loss':[],
           'train_acc':[],
           'val_loss':[],
           'val_acc':[],
           'test_loss':-1,
           'test_acc':-1
          }

train_state = make_train_state(args)

if not torch.cuda.is_available():
    args.cuda = False
args.device = torch.device('cuda' if args.cuda else 'cpu')

# 데이터 셋과 vectorizer
dataset = WebtoonDataset.load_dataset_and_make_vectorizer(args.webtoon_csv)
vectorizer = dataset.get_vectorizer()
# 모델
classifier = DescriptionClassifier(num_features=len(vectorizer.description_vocab),
                                   num_classes =len(vectorizer.genre_vocab))
classifier = classifier.to(args.device)

import torch.nn as nn
loss_func = nn.CrossEntropyLoss()
optimizer = optim.Adam(classifier.parameters(), lr = args.learning_rate)


batch_generator = generate_batches(dataset,
                                       batch_size=args.batch_size,
                                       device = args.device)

# 훈련 반복

