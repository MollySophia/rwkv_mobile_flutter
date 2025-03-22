# RWKV Demos

## 技术架构

- 前端: [flutter](https://github.com/MollySophia/rwkv_mobile_flutter/tree/master/example)
- adapter (dart ffi): [本项目](https://github.com/MollySophia/rwkv_mobile_flutter)
- 后端 (C++): [rwkv-mobile](https://github.com/MollySophia/rwkv-mobile)
- 权重: [mollysama/rwkv-mobile-models](https://huggingface.co/mollysama/rwkv-mobile-models/tree/main)

## 功能矩阵

| 功能              | Android | Android-QNN | iOS | macOS | Windows | Linux |
| ----------------- | :-----: | :---------: | :-: | :---: | :-----: | :---: |
| Chat              |   ✅    |     ✅      | ✅  |  ✅   |   ✅    |       |
| Othello           |   ✅    |             | ✅  |  ✅   |   ✅    |       |
| English Vision QA |   ✅    |             |     |       |         |       |
| English Audio QA  |   ✅    |             |     |       |         |       |
| English ASR       |   ✅    |             |     |       |         |       |
| Chinese ASR       |   🚧    |             |     |       |         |       |
| Sudoku            |   🚧    |             |     |       |         |       |
| 15Puzzle          |   🚧    |             |     |       |         |       |

## TODO

- Update readme
- Add download links

## prompt settings

prompt

|            | force-chinese on | force-chinese off |
| ---------- | ---------------- | ----------------- |
| reason on  | `<think>嗯`      | `<think`          |
| reason off | ???              | ???               |
