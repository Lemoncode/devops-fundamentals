import { getAvg } from './avarageService';
import axios from 'axios';

document.addEventListener('DOMContentLoaded', () => {
    const url = `${process.env.API_URL}/scores`;
    axios.get(url)
        .then(({ data }) => {
            console.log(data);
            const { scores } = data;
            const averageScore = getAvg(scores);
            const messageToDisplay = `average score ${averageScore}`;
            document.write(messageToDisplay);
        })
        .catch(console.error);
});