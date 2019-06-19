import http from 'http'
import express from 'express'
import { ApolloServer } from 'apollo-server-express'

import UserModel from './models/user'

import { typeDefs, resolvers } from './schema'

import sequelize from './db'
import { IContext } from './types';
import pubsub from './pubsub';

async function main () {

    await Promise.all([
        UserModel.syncTable()
    ])

    const app = express()

    const server = new ApolloServer({
        typeDefs,
        resolvers,
        context: (req): IContext => ({
            models: {
                user: new UserModel(sequelize)
            }
        })
    })

    server.applyMiddleware({ app, path: '/' })

    app.get('/healthcheck', (req, res) => res.status(200).send({ healthy: true }))

    const httpServer = http.createServer(app)

    server.installSubscriptionHandlers(httpServer)

    httpServer.listen(parseInt(process.env.PORT || '8080'))

    console.log('server online')
}


main().catch(err => {
    console.error(err)
    process.exit(1)
})
