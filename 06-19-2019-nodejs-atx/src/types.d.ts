import { Context } from "apollo-server-core";
import UserModel from "./models/user";

interface IContext extends Context {
    models: {
        user: UserModel
    }
}