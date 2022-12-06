import torch
import torch.nn as nn
import torch.nn.functional as F
class DescriptionClassifier(nn.Module):
    def __init__(self, num_features,  hidden_dim1, hidden_dim2,num_classes):
        super(DescriptionClassifier, self).__init__()
        self.fc1 = nn.Linear(in_features=num_features,
                             out_features=hidden_dim1)
        self.fc2 = nn.Linear(in_features=hidden_dim1,
                             out_features=hidden_dim2)
        self.fc3 = nn.Linear(in_features=hidden_dim2,
                             out_features=num_classes)

    def forward(self, x_in, apply_softmax = False):
        intermediate1 = F.relu(F.dropout(self.fc1(x_in), p=0.5))
        intermediate2 = F.relu(self.fc2(intermediate1))
        y_out = self.fc3(intermediate2).squeeze()
        if apply_softmax:
            y_out = torch.softmax(y_out)

        return y_out