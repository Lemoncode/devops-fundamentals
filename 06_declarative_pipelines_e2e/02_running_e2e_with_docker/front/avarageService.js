const sum = (numbers) => numbers.reduce((acc, curr) => acc + curr, 0);
export const getAvg = (scores) => sum(scores) / scores.length;