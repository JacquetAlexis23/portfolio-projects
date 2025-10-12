# Technical Architecture & Implementation Details

## 🏗️ System Architecture Overview

This document provides in-depth technical documentation for the Transformer-based Neural Machine Translation system.

---

## 📊 Model Architecture

### Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                    TRANSFORMER ARCHITECTURE                  │
├─────────────────────────────────────────────────────────────┤
│  Input Sequence                                             │
│       ↓                                                     │
│  ┌─────────────┐    ┌──────────────────────────────────┐   │
│  │   ENCODER   │    │           DECODER                │   │
│  │             │    │                                  │   │
│  │ ┌─────────┐ │    │ ┌─────────┐  ┌─────────────────┐ │   │
│  │ │ Layer N │ │    │ │ Layer N │  │  Cross-Attention │ │   │
│  │ └─────────┘ │    │ └─────────┘  └─────────────────┘ │   │
│  │     ...     │───▶│     ...              ↑           │   │
│  │ ┌─────────┐ │    │ ┌─────────┐          │           │   │
│  │ │ Layer 1 │ │    │ │ Layer 1 │──────────┘           │   │
│  │ └─────────┘ │    │ └─────────┘                      │   │
│  │             │    │                                  │   │
│  │ ┌─────────┐ │    │ ┌──────────────────────────────┐ │   │
│  │ │Embedding│ │    │ │       Embedding              │ │   │
│  │ │+Pos.Enc.│ │    │ │       +Pos.Enc.              │ │   │
│  │ └─────────┘ │    │ └──────────────────────────────┘ │   │
│  └─────────────┘    └──────────────────────────────────┘   │
│       ↑                              ↓                     │
│   Source Text                  Output Probabilities        │
└─────────────────────────────────────────────────────────────┘
```

### Mathematical Foundations

#### Multi-Head Attention Mechanism

The core innovation of the Transformer is the attention mechanism:

```
Attention(Q,K,V) = softmax(QK^T / √d_k)V
```

Where:
- **Q (Query)**: Current token seeking information
- **K (Key)**: Tokens being attended to  
- **V (Value)**: Information to be extracted
- **d_k**: Dimension of key vectors (for scaling)

#### Multi-Head Formulation

```
MultiHead(Q,K,V) = Concat(head_1, ..., head_h)W^O

where head_i = Attention(QW^Q_i, KW^K_i, VW^V_i)
```

**Benefits**:
- **Parallel Processing**: Multiple attention patterns simultaneously
- **Diverse Representations**: Different heads capture different relationships
- **Scalability**: Efficient computation through matrix operations

#### Positional Encoding

Since Transformers lack recurrent connections, positional information is injected via sinusoidal encodings:

```
PE(pos, 2i) = sin(pos / 10000^(2i/d_model))
PE(pos, 2i+1) = cos(pos / 10000^(2i/d_model))
```

**Advantages**:
- **Deterministic**: No learnable parameters required
- **Extrapolation**: Can handle sequences longer than training data
- **Uniqueness**: Each position has a unique encoding

---

## 🔧 Implementation Details

### Layer Specifications

#### Encoder Layer
```python
class EncoderLayer(tf.keras.layers.Layer):
    """
    Single encoder layer implementing:
    1. Multi-head self-attention
    2. Position-wise feed-forward network
    3. Residual connections and layer normalization
    """
    
    def __init__(self, d_model, n_heads, d_ff, dropout_rate):
        self.mha = MultiHeadAttention(d_model, n_heads)
        self.ffn = PositionwiseFeedForward(d_model, d_ff)
        self.layernorm1 = LayerNormalization(epsilon=1e-6)
        self.layernorm2 = LayerNormalization(epsilon=1e-6)
        self.dropout1 = Dropout(dropout_rate)
        self.dropout2 = Dropout(dropout_rate)
    
    def call(self, x, mask, training):
        # Self-attention sublayer
        attn_output = self.mha(x, x, x, mask)
        attn_output = self.dropout1(attn_output, training=training)
        out1 = self.layernorm1(x + attn_output)  # Residual connection
        
        # Feed-forward sublayer
        ffn_output = self.ffn(out1)
        ffn_output = self.dropout2(ffn_output, training=training)
        out2 = self.layernorm2(out1 + ffn_output)  # Residual connection
        
        return out2
```

#### Decoder Layer
```python
class DecoderLayer(tf.keras.layers.Layer):
    """
    Single decoder layer implementing:
    1. Masked multi-head self-attention
    2. Multi-head cross-attention (encoder-decoder)
    3. Position-wise feed-forward network
    4. Residual connections and layer normalization
    """
    
    def call(self, x, enc_output, look_ahead_mask, padding_mask, training):
        # Masked self-attention
        attn1 = self.mha1(x, x, x, look_ahead_mask)
        attn1 = self.dropout1(attn1, training=training)
        out1 = self.layernorm1(attn1 + x)
        
        # Cross-attention
        attn2 = self.mha2(out1, enc_output, enc_output, padding_mask)
        attn2 = self.dropout2(attn2, training=training)
        out2 = self.layernorm2(attn2 + out1)
        
        # Feed-forward
        ffn_output = self.ffn(out2)
        ffn_output = self.dropout3(ffn_output, training=training)
        out3 = self.layernorm3(ffn_output + out2)
        
        return out3
```

### Attention Mechanisms

#### Scaled Dot-Product Attention
```python
def scaled_dot_product_attention(q, k, v, mask):
    """
    Calculate the attention weights and apply to values
    
    Args:
        q: query shape (..., seq_len_q, depth)
        k: key shape (..., seq_len_k, depth)
        v: value shape (..., seq_len_v, depth_v)
        mask: Float tensor with shape broadcastable 
              to (..., seq_len_q, seq_len_k). Defaults to None.
    
    Returns:
        output, attention_weights
    """
    matmul_qk = tf.matmul(q, k, transpose_b=True)  # (..., seq_len_q, seq_len_k)
    
    # Scale matmul_qk
    dk = tf.cast(tf.shape(k)[-1], tf.float32)
    scaled_attention_logits = matmul_qk / tf.math.sqrt(dk)
    
    # Add the mask to the scaled tensor
    if mask is not None:
        scaled_attention_logits += (mask * -1e9)  
    
    # Softmax is normalized on the last axis (seq_len_k)
    attention_weights = tf.nn.softmax(scaled_attention_logits, axis=-1)
    
    output = tf.matmul(attention_weights, v)  # (..., seq_len_q, depth_v)
    
    return output, attention_weights
```

#### Multi-Head Attention Implementation
```python
class MultiHeadAttention(tf.keras.layers.Layer):
    def __init__(self, d_model, num_heads):
        super(MultiHeadAttention, self).__init__()
        self.num_heads = num_heads
        self.d_model = d_model
        
        assert d_model % self.num_heads == 0
        
        self.depth = d_model // self.num_heads
        
        self.wq = tf.keras.layers.Dense(d_model)
        self.wk = tf.keras.layers.Dense(d_model)
        self.wv = tf.keras.layers.Dense(d_model)
        
        self.dense = tf.keras.layers.Dense(d_model)
        
    def split_heads(self, x, batch_size):
        """Split the last dimension into (num_heads, depth)"""
        x = tf.reshape(x, (batch_size, -1, self.num_heads, self.depth))
        return tf.transpose(x, perm=[0, 2, 1, 3])
    
    def call(self, v, k, q, mask):
        batch_size = tf.shape(q)[0]
        
        q = self.wq(q)  # (batch_size, seq_len, d_model)
        k = self.wk(k)  # (batch_size, seq_len, d_model)
        v = self.wv(v)  # (batch_size, seq_len, d_model)
        
        q = self.split_heads(q, batch_size)  # (batch_size, num_heads, seq_len_q, depth)
        k = self.split_heads(k, batch_size)  # (batch_size, num_heads, seq_len_k, depth)
        v = self.split_heads(v, batch_size)  # (batch_size, num_heads, seq_len_v, depth)
        
        scaled_attention, attention_weights = scaled_dot_product_attention(q, k, v, mask)
        
        scaled_attention = tf.transpose(scaled_attention, perm=[0, 2, 1, 3])
        
        concat_attention = tf.reshape(scaled_attention, 
                                    (batch_size, -1, self.d_model))
        
        output = self.dense(concat_attention)
        
        return output
```

---

## 🎯 Training Strategy

### Learning Rate Scheduling

The Transformer uses a custom learning rate schedule:

```python
class CustomSchedule(tf.keras.optimizers.schedules.LearningRateSchedule):
    def __init__(self, d_model, warmup_steps=4000):
        super(CustomSchedule, self).__init__()
        
        self.d_model = d_model
        self.d_model = tf.cast(self.d_model, tf.float32)
        self.warmup_steps = warmup_steps
        
    def __call__(self, step):
        step = tf.cast(step, tf.float32)
        arg1 = tf.math.rsqrt(step)
        arg2 = step * (self.warmup_steps ** -1.5)
        
        return tf.math.rsqrt(self.d_model) * tf.math.minimum(arg1, arg2)
```

**Learning Rate Phases**:
1. **Warmup**: Linear increase for first 4000 steps
2. **Decay**: Inverse square root decay thereafter

### Loss Function

```python
def loss_function(real, pred, loss_object):
    mask = tf.math.logical_not(tf.math.equal(real, 0))
    loss_ = loss_object(real, pred)
    
    mask = tf.cast(mask, dtype=loss_.dtype)
    loss_ *= mask
    
    return tf.reduce_sum(loss_)/tf.reduce_sum(mask)
```

**Key Features**:
- **Masked Loss**: Ignores padding tokens
- **Sparse Categorical**: Efficient for large vocabularies
- **From Logits**: Numerical stability

---

## 📊 Data Pipeline

### Preprocessing Pipeline

```python
class DataPreprocessor:
    def __init__(self, vocab_size=8000):
        self.tokenizer_en = None
        self.tokenizer_es = None
        self.vocab_size = vocab_size
    
    def build_tokenizers(self, corpus_en, corpus_es):
        """Build subword tokenizers for both languages"""
        self.tokenizer_en = tfds.deprecated.text.SubwordTextEncoder.build_from_corpus(
            corpus_en, target_vocab_size=self.vocab_size)
        self.tokenizer_es = tfds.deprecated.text.SubwordTextEncoder.build_from_corpus(
            corpus_es, target_vocab_size=self.vocab_size)
    
    def encode_examples(self, en_sentence, es_sentence):
        """Encode sentence pairs for training"""
        en_sentence = [self.vocab_size] + self.tokenizer_en.encode(en_sentence) + [self.vocab_size + 1]
        es_sentence = [self.vocab_size] + self.tokenizer_es.encode(es_sentence) + [self.vocab_size + 1]
        
        return en_sentence, es_sentence
    
    def filter_max_length(self, x, y, max_length=40):
        """Filter sequences that are too long"""
        return tf.logical_and(tf.size(x) <= max_length, tf.size(y) <= max_length)
    
    def create_dataset(self, corpus_en, corpus_es, buffer_size=20000, batch_size=64):
        """Create training dataset"""
        dataset = tf.data.Dataset.from_generator(
            lambda: zip(corpus_en, corpus_es),
            output_types=(tf.string, tf.string))
        
        dataset = dataset.map(self.encode_examples)
        dataset = dataset.filter(self.filter_max_length)
        dataset = dataset.cache()
        dataset = dataset.shuffle(buffer_size)
        dataset = dataset.padded_batch(batch_size)
        dataset = dataset.prefetch(tf.data.AUTOTUNE)
        
        return dataset
```

### Text Cleaning Pipeline

```python
def clean_text(text):
    """Comprehensive text cleaning pipeline"""
    
    # Remove HTML tags
    text = re.sub(r'<[^>]+>', '', text)
    
    # Normalize whitespace
    text = re.sub(r'\s+', ' ', text)
    
    # Handle special characters
    text = re.sub(r'[^\w\s\.\,\?\!\:\;\-\(\)]', '', text)
    
    # Sentence segmentation with non-breaking prefixes
    text = apply_nonbreaking_prefixes(text)
    
    # Lowercase normalization
    text = text.lower()
    
    return text.strip()

def apply_nonbreaking_prefixes(text, prefixes):
    """Apply non-breaking prefix rules"""
    for prefix in prefixes:
        # Mark prefixes to prevent sentence splitting
        text = text.replace(prefix + '.', prefix + '$$$.')
    
    # Split sentences
    sentences = text.split('.')
    
    # Restore periods in prefixes
    sentences = [s.replace('$$$', '') for s in sentences]
    
    return [s.strip() for s in sentences if s.strip()]
```

---

## ⚡ Performance Optimizations

### Memory Optimization

```python
def memory_efficient_training():
    """Implement gradient accumulation for large models"""
    
    accumulate_grad_steps = 4
    
    with tf.GradientTape() as tape:
        for step in range(accumulate_grad_steps):
            batch = next(dataset_iterator)
            
            # Forward pass
            predictions = transformer(batch['inputs'], training=True)
            loss = loss_function(batch['targets'], predictions)
            
            # Scale loss for accumulation
            scaled_loss = loss / accumulate_grad_steps
        
        # Compute gradients
        gradients = tape.gradient(scaled_loss, transformer.trainable_variables)
        
        # Apply accumulated gradients
        optimizer.apply_gradients(zip(gradients, transformer.trainable_variables))
```

### Inference Optimization

```python
class OptimizedInference:
    def __init__(self, model_path):
        self.model = tf.saved_model.load(model_path)
        self.cache = {}
    
    @tf.function
    def translate_batch(self, inputs):
        """Optimized batch translation with TF function compilation"""
        return self.model(inputs, training=False)
    
    def translate_with_cache(self, text):
        """Translation with caching for repeated inputs"""
        text_hash = hash(text)
        
        if text_hash in self.cache:
            return self.cache[text_hash]
        
        translation = self.translate_batch([text])[0]
        self.cache[text_hash] = translation
        
        return translation
    
    def beam_search_decode(self, inputs, beam_width=4, max_length=50):
        """Beam search decoding for better translation quality"""
        # Implementation of beam search algorithm
        pass
```

### GPU Utilization

```python
def configure_gpu():
    """Configure GPU for optimal performance"""
    gpus = tf.config.experimental.list_physical_devices('GPU')
    
    if gpus:
        try:
            # Enable memory growth
            for gpu in gpus:
                tf.config.experimental.set_memory_growth(gpu, True)
            
            # Set virtual GPU configuration
            tf.config.experimental.set_virtual_device_configuration(
                gpus[0],
                [tf.config.experimental.VirtualDeviceConfiguration(memory_limit=4096)]
            )
            
        except RuntimeError as e:
            print(f"GPU configuration error: {e}")
```

---

## 🔍 Evaluation Metrics

### Automatic Evaluation

```python
def calculate_bleu_score(reference, candidate):
    """Calculate BLEU score for translation quality"""
    from nltk.translate.bleu_score import sentence_bleu
    
    reference_tokens = [reference.split()]
    candidate_tokens = candidate.split()
    
    return sentence_bleu(reference_tokens, candidate_tokens)

def calculate_meteor_score(reference, candidate):
    """Calculate METEOR score"""
    # Implementation depends on METEOR package
    pass

def evaluate_model(test_dataset):
    """Comprehensive model evaluation"""
    total_bleu = 0
    total_samples = 0
    
    for batch in test_dataset:
        predictions = model.predict(batch['inputs'])
        
        for ref, pred in zip(batch['references'], predictions):
            bleu = calculate_bleu_score(ref, pred)
            total_bleu += bleu
            total_samples += 1
    
    average_bleu = total_bleu / total_samples
    return {'bleu': average_bleu}
```

### Human Evaluation Framework

```python
def setup_human_evaluation():
    """Framework for human evaluation of translations"""
    
    evaluation_criteria = {
        'fluency': "How fluent is the translation? (1-5)",
        'adequacy': "How well does it convey the original meaning? (1-5)",
        'naturalness': "How natural does it sound? (1-5)"
    }
    
    return evaluation_criteria

def collect_human_ratings(translations, criteria):
    """Collect human ratings for translation quality"""
    ratings = {}
    
    for i, translation in enumerate(translations):
        ratings[i] = {}
        for criterion, description in criteria.items():
            rating = input(f"{description}: ")
            ratings[i][criterion] = int(rating)
    
    return ratings
```

---

## 🏗️ Production Deployment

### Model Serving

```python
class TransformerService:
    def __init__(self, model_path):
        self.model = tf.saved_model.load(model_path)
        self.preprocessing = TextPreprocessor()
        self.postprocessing = TextPostprocessor()
    
    def translate(self, text, source_lang='en', target_lang='es'):
        """Main translation endpoint"""
        
        # Preprocess
        clean_text = self.preprocessing.clean(text)
        tokens = self.preprocessing.tokenize(clean_text)
        
        # Translate
        translation_tokens = self.model(tokens)
        
        # Postprocess
        translation = self.postprocessing.detokenize(translation_tokens)
        clean_translation = self.postprocessing.clean(translation)
        
        return {
            'source': text,
            'translation': clean_translation,
            'confidence': self.calculate_confidence(translation_tokens),
            'processing_time': self.get_processing_time()
        }
    
    def health_check(self):
        """Service health check endpoint"""
        return {
            'status': 'healthy',
            'model_loaded': self.model is not None,
            'gpu_available': len(tf.config.list_physical_devices('GPU')) > 0,
            'memory_usage': self.get_memory_usage()
        }
```

### Monitoring & Logging

```python
import logging
from datetime import datetime

class TranslationLogger:
    def __init__(self, log_file='translation.log'):
        logging.basicConfig(
            filename=log_file,
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(__name__)
    
    def log_translation(self, source_text, translation, confidence, processing_time):
        """Log translation request details"""
        self.logger.info({
            'timestamp': datetime.now().isoformat(),
            'source_text': source_text[:100],  # Truncate for privacy
            'translation': translation[:100],
            'confidence': confidence,
            'processing_time': processing_time,
            'model_version': self.get_model_version()
        })
    
    def log_error(self, error_message, context):
        """Log error events"""
        self.logger.error({
            'timestamp': datetime.now().isoformat(),
            'error': error_message,
            'context': context
        })
```

---

This technical documentation provides the foundation for understanding, implementing, and extending the Transformer-based translation system in production environments.