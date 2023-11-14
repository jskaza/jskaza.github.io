---
layout: post
title: Toy ANN Interpretability Examples
date: 2023-11-14
category: AI
tags: deep-learning, interpretability, universal-approximation
---


Generally speaking, [universal approximation theorems](https://en.wikipedia.org/wiki/Universal_approximation_theorem) in theoretical AI research suggest that neural networks can represent diverse functions with the right weights, but they do not provide intuitive mechanistic interpretations of *how* a combination of weights work together to represent the function. Neural network training via optimization procedures aims to find the correct set of weights to represent the function, though this may or may not happen due to potential convergence issues.

Despite the "black box" nature of some neural networks, in which we are unable to decipher why a set of weights works well, there are some very simple toy networks where we can intuit how a particular neural network architecture will represent a function. While a far cry from some of the cool work being done in the nascent field of [mechanistic interpretability](https://transformer-circuits.pub/2022/mech-interp-essay/index.html), I find the simple examples below rather neat and elegant.


```python
import numpy as np
import tensorflow as tf
from sklearn.metrics import mean_squared_error
np.random.seed(42)
```


```python
# configs
x_size = 5
n_train = 100000
n_test = 10000
epochs = 1000
batch_size = 128
```

To start, let's generate simple feature matrices, drawn from a standard Gaussian. As we will see, the inclusion of negative numbers will be relevant.


```python
x_train = np.random.normal(0,1,(n_train,x_size))
x_test = np.random.normal(0,1,(n_test,x_size))
```

Next, we construct one of the simplest possible artificial neural network architectures. The forward pass multiplies each feature by a weight in the $W_1$ column vector, sums the products, and adds a bias term, $b_1$. The scalar result is passed to the ReLu ($max(0, .)$) function, with this output being multiplied by another weight, $w_2$. Another bias term, $b_2$, is added to reach an end result.


```python
model = tf.keras.Sequential(
    [
        tf.keras.layers.Input(shape=(x_size,)),
        tf.keras.layers.Dense(1, activation="relu"),
        tf.keras.layers.Dense(1)

    ]
)
model.save_weights("model.h5")
opt = tf.keras.optimizers.SGD(learning_rate=3e-3)
model.compile(optimizer=opt, loss="mse")
```

## Summation

We can train the above network to approximate a function that simply sums all of its inputs.

$$\mathit{X} =
\begin{bmatrix}
x_{1} & \dots & x_{n}
\end{bmatrix},
$$

$$
f(\mathit{X}) = \mathit{X}\mathbf{1} = \sum_{i=1}^{n}x_i = x_1 + \dots + x_n
$$


```python
# f(X)
y_train = x_train.sum(axis=1)
y_test = x_test.sum(axis=1)
```


```python
history = model.fit(x_train, y_train, epochs=epochs, batch_size=batch_size, verbose=False)
mean_squared_error(y_test, model.predict(x_test, verbose=False))
```




    0.00011352584577239452



We can see how learned weights and biases connect the network computation, which is really a composite function which we will denote $\hat{f}(\mathit{X})$, to the true function, $f(\mathit{X})$, mathematically

$$
\begin{align}
\hat{f}(\mathit{X}) &= w_2\max(0, \mathit{X}\mathit{W_1} + b_1) + b_2 \\
&= w_2\max(0, b_1 + \sum_{i=1}^{n}W_{1,i}x_i) + b_2 \\
&= w_2\max(0, b_1 + W_{1,1}x_1 + \dots + W_{1,n}x_n) + b_2 \\
\end{align}
$$

Temporarily ignoring the potential for the zeroing via the rectifier, we can simplify this to

$$
\hat{f}(\mathit{X}) = w_2b_1 + w_2\sum_{i=1}^{n}W_{1,i}x_i + b_2
$$

Ultimately, we just want to recover $\sum_{i=1}^{n}w_{i}x_i$ with $w_{i} = 1, \forall_{i \in \{1,\dots,n\}}$, thus the need to set

$$
\begin{align}
W_{1,i} &= w_2^{-1} \quad \forall_{i \in \{1,\dots,n\}}, \\
b_2 &=  -w_2b_1
\end{align}
$$

Importantly, since there are negative numbers in our data and we did choose to include the ReLu activation function, $b_1$ and $w_{1,i}$ must be chosen such that
$$
b_1 + \sum_{i=1}^{n}W_{1,i}x_i  > 0,
$$

which we notice depends on the distribution of $\mathit{X}$.

With this, we can substitute our relations to show that we recover the summation function.

$$
\begin{align}
w_2(b_1 + \sum_{i=1}^{n}w_2^{-1}x_i) - w_2b_1 &= w_2b_1 + w_2\sum_{i=1}^{n}w_2^{-1}x_i -w_2b_1 \\
&= \sum_{i=1}^{n}x_i
\end{align}
$$

We can now verify this with the learned weights in the simulation.


```python
for i, layer in enumerate(model.layers):
    print(f"layer {i+1} weights: " + ", ".join([str(x) for x in layer.get_weights()[0].flatten().tolist()]))
    print(f"layer {i+1} bias: " + ", ".join([str(x) for x in layer.get_weights()[1].flatten().tolist()]))
```

    layer 1 weights: 0.3583921492099762, 0.3583921790122986, 0.3583920896053314, 0.3583921790122986, 0.3583921492099762
    layer 1 bias: 2.801814556121826
    layer 2 weights: 2.790241241455078
    layer 2 bias: -7.817744731903076



```python
(np.allclose(
    # W_1*w_2 == 1
    model.layers[0].get_weights()[0].flatten()*
    model.layers[1].get_weights()[0],
    1,
             atol=1e-3)
and
np.allclose(
    # b_2 == -w_2*b_1
    model.layers[1].get_weights()[1].flatten(),
    -model.layers[1].get_weights()[0]*model.layers[0].get_weights()[1],
    atol = 1e-3)
)
```




    True




```python
# true function
print(
    "f(X) = " + " + ".join([f"x{i+1}" for i in range(x_size)])
)
```

    f(X) = x1 + x2 + x3 + x4 + x5



```python
# approximated function
recovered_m = (model.layers[0].get_weights()[0].flatten() * model.layers[1].get_weights()[0]).flatten().tolist()
recovered_c = (model.layers[0].get_weights()[1].flatten() * model.layers[1].get_weights()[0] + model.layers[1].get_weights()[1]).flatten()[0]
print(
    "f(X) = " + " + ".join([f"{round(recovered_m[i],2)}*x{i+1}" for i in range(x_size)]) + f" + {str(round(recovered_c, 2))}"
)
```

    f(X) = 1.0*x1 + 1.0*x2 + 1.0*x3 + 1.0*x4 + 1.0*x5 + -0.0


## Weighted Sum + Constant

We can now train the same network to approximate a *slightly* more complicated function that multiplies each input by a coefficient, sums them, and then adds a constant, akin to a linear model.

$$
\mathit{X} =
\begin{bmatrix}
x_{1} & \dots & x_{n}
\end{bmatrix},
$$

$$
\mathit{M} =
\begin{bmatrix}
m_{1} \\
\vdots \\
m_{n}
\end{bmatrix},
$$

$$
f(\mathit{X}) = \mathit{M}^T \mathit{X} + c = c + \sum_{i=1}^{n}m_ix_i = m_1x_1 + \dots + m_nx_n + c
$$

Note that the summation example above is a special case of this function.


```python
# f(X)
m = np.random.normal(0,1,x_size)
c = np.random.normal(0,1,1).flatten()[0]
y_train = (x_train*m).sum(axis=1) + c
y_test = (x_test*m).sum(axis=1) + c
```


```python
model.load_weights("model.h5")
history = model.fit(x_train, y_train, epochs=epochs, batch_size=batch_size, verbose=False)
mean_squared_error(y_test, model.predict(x_test, verbose=False))
```




    0.00010311098776760997



As we did above, we can derive some relations for optimally learned weights.

Recall that

$$
\begin{align}
\hat{f}(\mathit{X}) &= w_2\max(0, b_1 + \sum_{i=1}^{n}W_{1,i}x_i) + b_2
\end{align}
$$

and without the ReLU

$$
\begin{align}
\hat{f}(\mathit{X}) &= w_2b_1 + w_2\sum_{i=1}^{n}W_{1,i}x_i + b_2 \\
&= \underbrace{w_2b_1 + b_2}_c + \sum_{i=1}^{n}\underbrace{w_2W_{1,i}}_{m_i}x_i
\end{align}
$$

We see that we must select $W_1$, $w_2$, $b_1$, and $b_2$, such that $w_2b_1 + b_2 = c$ and $w_2W_{1,i} = m_i$ $\forall_{i \in \{1,\dots,n\}}$.


Let's verify these with the learned weights in the simulation.


```python
for i, layer in enumerate(model.layers):
    print(f"layer {i+1} weights: " + ", ".join([str(x) for x in layer.get_weights()[0].flatten().tolist()]))
    print(f"layer {i+1} bias: " + ", ".join([str(x) for x in layer.get_weights()[1].flatten().tolist()]))
```

    layer 1 weights: 0.589567244052887, 0.01935354806482792, -0.34266069531440735, -0.15244796872138977, 0.07748490571975708
    layer 1 bias: 2.502786159515381
    layer 2 weights: 2.4603865146636963
    layer 2 bias: -7.012039661407471



```python
(np.allclose(
    # w_2b_1 + b_2 == c
    model.layers[1].get_weights()[0][0]*model.layers[0].get_weights()[1] +
    model.layers[1].get_weights()[1],
    c,
    atol=1e-3)
and
 np.allclose(
    # w2w_1,i = m_i
    model.layers[1].get_weights()[0][0]*model.layers[0].get_weights()[0].flatten(),
    m,
    atol=1e-3)
)
```




    True




```python
# true function
print(
    "f(X) = " + " + ".join([str(round(x, 2)) + f"*x{i+1}" for i,x in enumerate(m)]) + f" + {str(round(c, 2))}"
)
```

    f(X) = 1.45*x1 + 0.05*x2 + -0.84*x3 + -0.38*x4 + 0.19*x5 + -0.85



```python
# approximated function
recovered_m = (model.layers[0].get_weights()[0].flatten() * model.layers[1].get_weights()[0]).flatten().tolist()
recovered_c = (model.layers[0].get_weights()[1].flatten() * model.layers[1].get_weights()[0] + model.layers[1].get_weights()[1]).flatten()[0]
print(
    "f(X) = " + " + ".join([str(round(x, 2)) + f"*x{i+1}" for i,x in enumerate(recovered_m)]) + f" + {str(round(recovered_c, 2))}"
)
```

    f(X) = 1.45*x1 + 0.05*x2 + -0.84*x3 + -0.38*x4 + 0.19*x5 + -0.85


## Product

As a final example, consider a product function

$$
f(\mathit{X}) = \prod_{i=1}^{n}x_i = x_1 \times \dots \times x_n
$$

Up until this point, the representations have been relatively easy because they leverage weighted sums, which directly corresponds to how neural networks compute. Representing the product becomes quite tricky and a rigorous investigation is beyond the scope of this post ([see here](https://stats.stackexchange.com/a/324008)). However, given *a priori* knowledge (and a constraint to positive numbers) we can leverage the fact that

$$
\log(\prod_{i=1}^{n}x_i) = \log(x_1) + \dots + \log(x_n)
$$

and we get a repeat of the summation representation.


```python
x_train = np.random.gamma(1, 1,(n_train,x_size))
x_test = np.random.gamma(1, 1,(n_test,x_size))
x_train_log = np.log(x_train)
x_test_log = np.log(x_test)
y_train_log = np.log(x_train.prod(axis=1))
y_test = x_test.prod(axis=1)
```


```python
model.load_weights("model.h5")
history = model.fit(x_train_log, y_train_log, epochs=epochs, batch_size=batch_size, verbose=False)
mean_squared_error(y_test, np.exp(model.predict(x_test_log, verbose=False)))
```




    7.515953185392041e-09




```python
for i, layer in enumerate(model.layers):
    print(f"layer {i+1} weights: " + ", ".join([str(x) for x in layer.get_weights()[0].flatten().tolist()]))
    print(f"layer {i+1} bias: " + ", ".join([str(x) for x in layer.get_weights()[1].flatten().tolist()]))
```

    layer 1 weights: 0.2527722120285034, 0.2527722418308258, 0.2527722418308258, 0.2527722418308258, 0.2527722120285034
    layer 1 bias: 4.003366947174072
    layer 2 weights: 3.956125497817993
    layer 2 bias: -15.83782958984375



```python
(np.allclose(
    # W_1*w_2 == 1
    model.layers[0].get_weights()[0].flatten()*
    model.layers[1].get_weights()[0],
    1,
    atol=1e-3)
and
np.allclose(
    # b_2 == -w_2*b_1
    model.layers[1].get_weights()[1].flatten(),
    -model.layers[1].get_weights()[0]*model.layers[0].get_weights()[1],
    atol = 1e-3)
)
```




    True


