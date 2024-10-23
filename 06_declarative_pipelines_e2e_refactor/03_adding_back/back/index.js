const express = require("express");
const cors = require("cors");
const app = express();
require("dotenv").config();

app.use(cors());

app.get("/scores", (_, res) => {
  res.json({ scores: [90, 75, 60, 99, 94, 30] });
});

app.listen(process.env.PORT, () => {
  console.log(`App running on ${process.env.PORT}`);
});
