from webtoon_vectorizer import WebtoonVectorizer
from sklearn.model_selection import train_test_split
from torch.utils.data import Dataset
from webtoon_dataloader import *
import pandas as pd
import numpy as np


class WebtoonDataset(Dataset):
    def __init__(self, webtoon_df, vectorizer):
        self.webtoon_df = webtoon_df
        self._vectorizer = vectorizer

        # train, val, test split

        train_ind,test_ind,train_y,test_y = train_test_split(
            np.array(range(len(webtoon_df))),webtoon_df.genre,
            stratify=webtoon_df.genre,random_state=493
        )
        train_ind,val_ind, train_y, val_y = train_test_split(
            train_ind,train_y,
            stratify=train_y,random_state=493
        )


        self.train_df = self.webtoon_df.iloc[train_ind]
        self.train_size = len(self.train_df)
        self.val_df = self.webtoon_df.iloc[val_ind]
        self.val_size = len(self.val_df)
        self.test_df = self.webtoon_df.iloc[test_ind]
        self.test_size = len(self.test_df)

        self._lookup_dict = {'train': (self.train_df, self.train_size),
                             'val': (self.val_df, self.val_size),
                             'test': (self.test_df, self.test_size)}

        self.set_split('train')

    def set_split(self, split='train'):
        self.target_split = split
        self._target_df, self._target_size = self._lookup_dict[split]

    def get_target_df(self):
        return self._target_df

    def take_preprocess_text(self, text):
        text = preprocess_text(text)
        return self._vectorizer.vectorize(text)

    @classmethod
    def load_dataset_and_make_vectorizer(cls, webtoon_csv1='./data/naver.csv',webtoon_csv2='./data/naver_challenge.csv'):
        webtoon_w = pd.read_csv(webtoon_csv1)[['title', 'genre', 'description']]
        if webtoon_csv2 != '':
            webtoon_c = pd.read_csv(webtoon_csv2)[['title', 'genre', 'description']]
            webtoon_df = pd.concat([webtoon_w, webtoon_c])
        else :
            webtoon_df = webtoon_w
        webtoon_df['genre'] = webtoon_df['genre'].apply(lambda s: s.split()[-1])

        cor_gen_dic = {'액션': 'action', '개그': 'comic', '드라마': 'drama', '로맨스': 'romance', '스릴러': 'thrill',
                       '스포츠': 'sports',
                       '일상': 'daily', '판타지': 'fantasy', '무협/사극': 'historical', '감성': 'pure'}
                       # 'historical': 'action',
                       # 'sports': 'action'}
        webtoon_df['genre'] = [cor_gen_dic.get(g,g) for g in webtoon_df['genre']]

        webtoon_df['description'] = webtoon_df['description'].apply(preprocess_text)
        # webtoon_df['description'] = webtoon_df['description'].apply(text_preprocess_okt)
        # webtoon_df['description'] = webtoon_df['description'].apply(text_preprocess_re)
        # webtoon_df['description'] = webtoon_df['description'].apply(preprocess_text_stop)

        return cls(webtoon_df, WebtoonVectorizer.from_dataframe(webtoon_df))

    def get_vectorizer(self):
        return self._vectorizer

    def __len__(self):
        return self._target_size

    def __getitem__(self, index):
        row = self._target_df.iloc[index]

        description_vector = \
            self._vectorizer.vectorize(row.description)
        genre_index = \
            self._vectorizer.genre_vocab.lookup_token(row.genre)

        return {'x_data': description_vector,
                'y_target': genre_index}

    def get_num_batches(self, batch_size):
        return len(self)// batch_size

