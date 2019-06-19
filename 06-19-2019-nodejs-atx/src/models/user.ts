import UserTable from '../tables/user'
import { Sequelize } from 'sequelize-typescript';

export default class UserModel {
    static syncTable () : PromiseLike<any> {
        return UserTable.sync({
            // force: true
        })
    }

    constructor (private sequelize: Sequelize) {}

    getAll () : PromiseLike<UserTable[]> {
        return UserTable.findAll()
    }

    create ({ name }) : PromiseLike<UserTable> {
        return UserTable.create({ name })
    }

    async update (id, { name }) : Promise<UserTable> {
        const user = await UserTable.findByPk(id)

        if (!user) {
            throw new Error(`Cannot find user with id ${id}`)
        }

        await user.update({
            name
        })

        return user
    }
}
