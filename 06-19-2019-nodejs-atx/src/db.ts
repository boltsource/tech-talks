import { Sequelize } from 'sequelize-typescript'

const sequelize = new Sequelize({
    host: process.env.SQL_HOST || 'localhost',
    database: process.env.SQL_DATABASE || 'database',
    dialect: 'postgres',
    username: process.env.SQL_USERNAME || 'user',
    password: process.env.SQL_PASSWORD || 'password',
    modelPaths: [`${__dirname}/tables`]
});

export default sequelize