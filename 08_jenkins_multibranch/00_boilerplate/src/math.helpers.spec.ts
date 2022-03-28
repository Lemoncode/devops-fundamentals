import { sum } from './math.helpers';

describe('math.helpers specs', () => {
  it('should return 3 when it feeds a equals 1 and b equals 2', () => {
    // Arrange
    const a = 1;
    const b = 2;

    // Act
    const result = sum(a, b);

    // Assert
    expect(result).toEqual(3);
  });
});
