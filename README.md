# PaperSynth
---

![Imgur](https://thumbs.gfycat.com/BareCompleteGreatargus-size_restricted.gif)

PaperSynth is a project that aims to read keywords you've written on a piece of paper and covert it into synthesizers you can play on the phone.

It uses a convolutional neural network model to do handwriting recognition in photos.

This project uses Apple's Vision framework in conjunction with CoreML to create bounding boxes around the visible text.

Eventually, the goal is to read all forms of synthesis block diagrams for music and generate digital equivalents for the same. Currently, it uses a paradigm I refer to as _StackChain_. Stack-chain treats signal flow as a stack where you pipe input/generate data at the first layer and eventually, get an output through the last layer of the stack.

---

## Training the ConvNet:


### First, we create the dataset:

To begin, download the Chars74k handwriting dataset from [Here](http://www.ee.surrey.ac.uk/CVSSP/demos/chars74k/). Download the EnglishHnd.tgz archive.

The samples from EnglishHnd are organized in the format `Sample0xx`, where `xx` represents the current sample number. Each sample contains a letter or a number. Samples 001 through 010 contain numbers and we can remove these.

Navigate to the JPG-PNG-to-MNIST-NN-Format directory and follow the instructions in the README.md. The instructions guide you towards being able to store data in a way that can be classified easier.

Once you're done there, you should have four files:

```
test-images-idx3-ubyte.gz
test-labels-idx1-ubyte.gz
train-images-idx3-ubyte-gz
train-labels-idx1-ubyte.gz
```

For convenience, in case things go south for you, these four files come included with repository.

Go to the Handwriting directory here and you're ready to start training.


### Let's setup the directory structure

Now, your Handwriting directory looks something like this:
```
├── MNIST_Chars74k_Jupyter.ipynb
├── main.py
├── utils/
├── share/
├── data
│   ├── old
│   │   ├── test-images-idx3-ubyte.gz
│   │   └── test-labels-idx1-ubyte.gz
│   │   ├── train-images-idx3-ubyte.gz
│   │   └── test-labels-idx1-ubyte.gz
│   ├── test-images-idx3-ubyte.gz
│   ├── test-labels-idx1-ubyte.gz
│   ├── train-images-idx3-ubyte.gz
│   ├── train-labels-idx1-ubyte.gz
```
In order to run the training process, you will need the following:

```
keras
tensorflow
h5py
PIL
numpy
scipy
scikit
```

In order to allow you to tool around with the dataset, a Jupyter notebook named `MNIST_Chars74k_Jupyter.ipynb` has been included.

---

### Resource credits: 

- [Vision/coreml tutorial By Martin Mitrevski](https://martinmitrevski.com/2017/10/19/text-recognition-using-vision-and-coreml/)
- [MNIST on Keras](https://github.com/fchollet/keras/blob/master/examples/mnist_cnn.py)
- [Levenshtein Distance](https://gist.github.com/TheDarkCode/341ec5b84c078a0be1887c2c58f6d929)







