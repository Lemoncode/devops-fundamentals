import axios from 'axios';
import { envConstants } from './env.constants';

describe('api specs', () => {
  it('should return "The result is 5" when it feeds a equals 2 and b equals 3', async () => {
    // Arrange
    const a = 2;
    const b = 3;
    const url = `${envConstants.BASE_API_URL}/api/sum?a=${a}&b=${b}`;

    // Act
    const { data } = await axios.get(url);

    // Assert
    expect(data).toEqual('The result is 5');
  });
});