const router = require("express").Router();
const { privatePosts } = require("../db");
const checkAuth = require("../middleware/checkAuth");

router.get("/", checkAuth, (req, res) => {
  res.json({ privatePosts });
});

router.post("/create-post", checkAuth, (req, res) => {
  const { postTitle, postDesc } = req.body;

  if (!postTitle && !postDesc) {
    return res.status(400).json({
      errors: [
        {
          msg: "Enter post title or description",
        },
      ],
    });
  }

  privatePosts.push({
    title: postTitle,
    content: postDesc,
  });

  res.send("Post created");
});

module.exports = router;
