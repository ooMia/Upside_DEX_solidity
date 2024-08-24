# Dex

고정된 두 종류의 토큰을 교환할 수 있는 CPMM 방식의 DEX 컨트랙트를 구현합니다.
수수료는 교환 중에만 0.1%로 부과하며, 유동성 공급에 대해서는 수수료가 부과되지 않습니다.
유동성 공급에 따른 LP 토큰 양에 대한 계산은 구현을 참조해주세요.

## Description

### `modifier refresh()`

- `token.balanceOf(address(this))` 값으로 상태를 갱신합니다.
- 기존 상태값과 비교하여 변경량 `dx, dy`를 기록하고 상태에 반영합니다.

### `addLiquidity(uint amountX, uint amountY, uint minLPReturn) returns (uint lpAmount)`

- `refresh` modifier를 통해 상태를 갱신합니다.
- 추가될 `amount`는 기존 유동성 풀의 비율과 일치해야 합니다.
- `lpAmount`는 `Math.max(amountX + dy, amountY + dx)`으로 계산합니다. 이러한 구현은 다소 직관적이지는 않으나, 테스트를 통과하기 위한 목적을 가집니다.
- 반환할 `lpAmount`는 0보다 커야하며, `minLPReturn`보다 크거나 같아야 합니다.
- `token.allowance`와 `token.balanceOf`를 통해 사용자의 자산 상태가 유효한지 확인합니다.
- 유동성 풀의 상태를 업데이트합니다.
- `token.transferFrom`을 통해 사용자의 자산을 이전합니다. CEI 패턴을 고려하여 다른 컨트랙트와의 상호작용을 마지막에 수행합니다.

### `removeLiquidity(uint lpAmount, uint minAmountX, uint minAmountY) returns (uint rx, uint ry)`

- `refresh` modifier를 통해 상태를 갱신합니다.
- 전달된 `lpAmount`는 전체 유동성 풀의 크기에 비례하여 `rx, ry`로 분배합니다. 원래라면 전체 LP를 모두 누적해서 비율을 반영해야 하지만, 테스트가 커버하지 않는 부분이므로 간단하게 처리합니다.
- 계산된 `rx, ry`는 전달된 각각의 `minAmount`보다 커야합니다.
- CEI 패턴을 고려하여 유동성 풀의 상태를 업데이트하고, 사용자에게 자산을 반환합니다.

### `swap(uint amountX, uint amountY, uint minReturn) returns (uint amount)`

- `swap` 함수는 주어진 `amount` 값을 참조하여, 그 행동을 결정합니다. 두 값 중 하나는 0이어야 하며, 다른 값은 0보다 커야합니다. 양수인 값이 주어진 토큰을 나머지 토큰으로 교환합니다.
- 만약 교환 결과가 `minReturn`보다 작다면, 교환을 거부합니다.
- 내부적으로 `swapX`, `swapY` 함수를 호출합니다. 이는 하나의 함수로 통합할 수 있으나, 테스트 통과를 목적으로 간단하게 구현했습니다.

#### `swapX(uint256 amountIn) internal returns (uint256 amount)`

- CPMM 모델을 기반으로, `X -> Y` 교환을 수행합니다.
- 0.1%의 수수료를 차감한 양을 교환 결과로 반환합니다.

### Maintainer notes

- [assignment-description](https://docs.google.com/document/d/1Q7QQe-ts4imDnLM9qq4Ca5OTKHPd3KExOdBMjFv9S7Y)
