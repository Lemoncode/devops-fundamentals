import axios from "axios";
import * as averageService from "./avarage.service.js";
import "./styles.css";

document.addEventListener("DOMContentLoaded", () => {
  const url = `${process.env.API_URL}/scores`;
  axios
    .get(url)
    .then(({ data }) => {
      const { scores } = data;

      const averageScore = averageService.getAvg(scores);
      const totalScore = averageService.getTotalScore(scores);

      const messageToDisplayAvg = `average score ${averageScore} `;
      const messageToDisplayTotal = `total score ${totalScore}`;

      const spanAvg = document.createElement("span");
      spanAvg.innerHTML = messageToDisplayAvg;
      const spanTotal = document.createElement("span");
      spanTotal.innerHTML = messageToDisplayTotal;

      document.getElementById("container").appendChild(spanAvg);
      document.getElementById("container").appendChild(spanTotal);
    })
    .catch(console.error);
});
