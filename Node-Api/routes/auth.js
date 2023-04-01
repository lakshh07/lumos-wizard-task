const router = require("express").Router();
const { check, validationResult } = require("express-validator");
const { users } = require("../db");
const bycrypt = require("bcrypt");
const JWT = require("jsonwebtoken");

router.post(
  "/signup",
  [
    check("email", "Please provide a valid email").isEmail(),
    check(
      "password",
      "Please provide a password that is greater than 6 characters"
    ).isLength({ min: 6 }),
  ],
  async (req, res) => {
    const { password, email } = req.body;

    const errors = validationResult(req);

    if (!errors.isEmpty()) {
      return res.status(400).json({
        errors: errors.array(),
      });
    }

    let user = users.find((user) => {
      return user.email === email;
    });

    if (user) {
      return res.status(400).json({
        errors: [
          {
            msg: "This user already exists",
          },
        ],
      });
    }

    const hashedPassword = await bycrypt.hash(password, 10);

    users.push({
      email,
      password: hashedPassword,
    });

    const token = await JWT.sign(
      { email },
      "sjnujsbfuib3b2ib4i2b3i1b3i1bi13b",
      { expiresIn: 36000 }
    );

    res.json({ token });
  }
);

router.post("/login", async (req, res) => {
  const { password, email } = req.body;

  let user = users.find((user) => {
    return user.email === email;
  });

  if (!user) {
    return res.status(400).json({
      errors: [
        {
          msg: "Invalid Credentials",
        },
      ],
    });
  }

  let isMatch = await bycrypt.compare(password, user.password);

  if (!isMatch) {
    return res.status(400).json({
      errors: [
        {
          msg: "Invalid Credentials",
        },
      ],
    });
  }

  const token = await JWT.sign({ email }, "sjnujsbfuib3b2ib4i2b3i1b3i1bi13b", {
    expiresIn: 36000,
  });

  res.json({ token });
});

router.get("/all", (req, res) => {
  res.json(users);
});

module.exports = router;
