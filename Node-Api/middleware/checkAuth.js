const JWT = require("jsonwebtoken");

module.exports = async (req, res, next) => {
  const token = req.header("x-auth-token");

  if (!token) {
    return res.status(400).json({
      errors: [
        {
          msg: "No token found",
        },
      ],
    });
  }

  try {
    let user = await JWT.verify(token, "sjnujsbfuib3b2ib4i2b3i1b3i1bi13b");
    req.user = user.email;
    next();
  } catch (error) {
    return res.status(400).json({
      errors: [
        {
          msg: "Token Invalid",
        },
      ],
    });
  }
};
