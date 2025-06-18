module.exports = (config) => {
  config.module.rules.push({
    test: /\.(woff(2)?|ttf|eot|svg)$/,
    type: 'asset/resource',
    generator: {
      filename: 'static/media/[name][ext]',
    },
  });

  return config;
};
