from webtoon_vocabulary import Vocabulary

from sklearn.feature_extraction.text import TfidfVectorizer
import string

import numpy as np
from collections import Counter
class WebtoonVectorizer :
    def __init__(self, description_vocab, genre_vocab):
        self.description_vocab = description_vocab
        self.genre_vocab = genre_vocab

    def vectorize(self, description):
        one_hot = np.zeros(len(self.description_vocab), dtype=np.float32)

        for token in description.split(' '):
            if token not in string.punctuation:
                one_hot[self.description_vocab.lookup_token(token)] = 1

        return one_hot

    # @classmethod
    # def from_dataframe_tfidf(clscls, webtoon_df):
    #     description_vocab = Vocabulary(add_unk=True)
    #     genre_vocab = Vocabulary(add_unk=False)
    #     for genre in sorted(webtoon_df.genre):
    #         genre_vocab.add_token(genre)



    @classmethod
    def from_dataframe(cls, webtoon_df, cutoff = 20):
        description_vocab = Vocabulary(add_unk=True)
        genre_vocab = Vocabulary(add_unk=False)
        for genre in sorted(webtoon_df.genre):
            genre_vocab.add_token(genre)

        word_counts = Counter()
        for description in webtoon_df.description:
            for word in description.split(" "):
                if word not in string.punctuation:
                    word_counts[word] +=1

        for word, count in word_counts.items():
            if count > cutoff:
                description_vocab.add_token(word)

        return cls(description_vocab, genre_vocab)


    @classmethod
    def from_serializable(cls, contents):
        description_vocab = Vocabulary.from_serializable(contents['description_vocab'])
        genre_vocab = Vocabulary.from_serializable(contents['genre_vocab'])

        return cls(description_vocab= description_vocab, genre_vocab = genre_vocab)

    def to_serializable(self):
        return {'description_vocab':self.description_vocab.to_serializable(),
                'genre_vocab':self.genre_vocab.to_serializable()}