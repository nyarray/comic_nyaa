import 'dart:collection';

class RecyclerQueue<T> {
  late final Queue<T> _queue;
  late final int maxSize;
  RecyclerQueue(this.maxSize) {
    this._queue = ListQueue(maxSize);
  }

  void add(T item) {
    while (_queue.length >= maxSize) {
      _queue.removeFirst();
    }
    return _queue.add(item);
  }

  bool remove(int index) {
    return _queue.remove(index);
  }

  T get(int index) {
    return _queue.elementAt(index);
  }

  void put(T item) {
    _queue.add(item);
  }

  bool get isEmpty => _queue.isEmpty;
  bool get isNotEmpty => _queue.isNotEmpty;
  int get length => _queue.length;
  T get first => _queue.first;
  T get last => _queue.last;

  // T operator [](int index) {
  //   return _queue.elementAt(index);
  // }

  // void operator []=(int index, T value) {
  //   if (index >= _queue.length) {
  //     _queue.length = index + 1; // 扩容
  //   }
  //   _queue[index] = value;
  // }
}
