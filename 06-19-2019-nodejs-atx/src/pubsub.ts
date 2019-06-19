import { RedisPubSub } from 'graphql-redis-subscriptions';
import Redis from 'ioredis';

const options = {
    host: String(process.env.REDIS_HOST || 'localhost'),
    port: parseInt(process.env.REDIS_PORT || '6379'),
    retry_strategy: options => {
        return Math.max(options.attempt * 100, 3000)
    }
}

const pubsub = new RedisPubSub({
    publisher: new Redis(options),
    subscriber: new Redis(options)
})

export default pubsub
