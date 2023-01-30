import re

import torch
from konlpy.tag import Mecab, Okt
from torch.utils.data import DataLoader

okt = Okt()
with open("./korean_stopword.txt", "r", encoding="utf-8") as f:
    stopwords = [x.strip() for x in f.readlines() if x != "\n"]


def compute_accuracy(out, yb):
    preds = torch.argmax(out, dim=1)
    return (preds == yb).float().mean()


def preprocess_text(text):
    lem_words = []
    for w, p in okt.pos(text):
        if p in ["Noun", "Adjective", "Verb", "KoreanParticle"] and w not in stopwords:
            lem_words.append(w)
    text = " ".join(lem_words)
    return text


def preprocess_text_stop(text):
    lem_words = []
    for w, p in okt.pos(text):
        if p in ["Noun", "Adjective", "Verb", "KoreanParticle"] and w not in stopwords:
            if w not in stopwords:
                lem_words.append(w)
    text = " ".join(lem_words)
    return text


def text_preprocess_okt(text):
    text = " ".join(okt.nouns(text))
    return text


def text_preprocess_re(text):
    text = re.sub(r"([.,!?'])", r" \1", text)
    text = re.sub(r'[0-9.,!?~"\\<>\n\r]+', r" ", text)
    return text


def generate_batches(dataset, batch_size, shuffle=True, drop_last=True, device="cpu"):
    dataloader = DataLoader(
        dataset=dataset,
        batch_size=batch_size,
        shuffle=shuffle,
        drop_last=drop_last,
    )

    for data_dict in dataloader:
        out_data_dict = {}
        for name, tensor in data_dict.items():
            out_data_dict[name] = data_dict[name].to(device)
        yield out_data_dict


# print(preprocess_text('여기는 대구 경북 대학교입니다.'))
