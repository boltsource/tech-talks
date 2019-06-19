import { gql } from 'apollo-server-express'
import pubsub from './pubsub'
import { IContext } from './types';

const TOPICS = {
  userCreated: 'GQL:USER:CREATED'
}

export const typeDefs = gql`
    type Query {
        getUsers: [User]
    }

    type Mutation {
        createUser(name: String!): User
        updateUser(id: String!, name: String!): User
    }

    type Subscription {
        userCreated: User
        userUpdated(id: String!): User
    }

    type User {
        id: String!
        name: String!
    }
`

export const resolvers = {
    Query: {
        getUsers: (root, args, ctx: IContext) => ctx.models.user.getAll()
    },
    Mutation: {
        createUser: async (root, args, ctx: IContext) => {
          const user = await ctx.models.user.create({ name: args.name })

          await pubsub.publish(TOPICS.userCreated, { userCreated: user })

          return user
        },
        updateUser: async (root, args, ctx: IContext) => ctx.models.user.update(args.id, { name: args.name })
    },
    Subscription: {
      userCreated: {
        subscribe: () => pubsub.asyncIterator([TOPICS.userCreated])
      }
    }
}
