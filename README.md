The repository contains three matlab files:
- GetRIR.m
- DataCollection.m
- DataProcessing.m

GetRIR is a helper function to collect data. It can simply be called in Matlab
without any arguments to generate the room impulse response. Additionally it
returns the time vector for the impulse response and also the Discrete
Fourier Transform of the raw audio input. Here is an example call to this
funtion:

	[time_vector, RIR, fourier_transform] = GetRIR();

DataCollection file asks for the room name and gathers the specified number of
RIR samples. This sample is stored a matlab matrix and later saved as a file
that can be collected by matlab, python or many other tools. It can simply be
called without any arguments.

DataProcessing file searches for any mat files in the directory and processes
the impulse responses stored in the mat files. It extracts important features
from the data and saves it as a matlab variable.

After the variable with features is set in the workspace, the classification 
learner app in matlab can be used to train a SVM. The room values/labels should
be used as response in the training data set. With n-fold cross validation,
SVM can be trained and the resulting classifier can be exported to be used
for classifying rooms in real life situations. The RIR can simply be passed
to the exported classifier to obtain the predicted label. 
