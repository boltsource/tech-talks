import { DataTypes } from 'sequelize'
import { Table, Column, Model, PrimaryKey, IsUUID, NotNull, Default } from 'sequelize-typescript'

@Table
export default class UserTable extends Model<UserTable> {
    @IsUUID(4)
    @Default(DataTypes.UUIDV4)
    @PrimaryKey
    @Column
    id: string

    @Column
    name: string
}