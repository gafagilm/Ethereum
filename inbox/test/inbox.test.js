const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());
const { interface, bytecode } = require('../compile');
const INITIAL_MESSAGE = 'Hui there'

let accounts;

beforeEach(async () => {
    // get a list of all accounts
    accounts = await web3.eth.getAccounts();
    // use one of those accounts to deploy the contract
    inbox = await new web3.eth.Contract(JSON.parse(interface))
        .deploy({ data: bytecode, arguments: [INITIAL_MESSAGE]})
        .send({ from: accounts[0], gas: '1000000' });
});
describe('Inbox', () => {
    it ('deploys a contract', () => {
        console.log(inbox);
        assert.ok(inbox.options.address);
    });
    it ('has a default message', async () => {
        const message = await inbox.methods.message().call();
        assert.equal(message, INITIAL_MESSAGE);
    });
    it ('can change the message', async () => {
        await inbox.methods.setMessage('pezda there').send({ from: accounts[0], gas: '1000000' });
        const message = await inbox.methods.message().call();
        assert.equal(message, 'pezda there');
    });
});









/*class Car {
    park() {
        return 'stopped';
    }

    drive() {
        return 'vroom';
    }
}
let car;
beforeEach(() => {
    car = new Car();
});

describe('Car', () => {
    it('can park', () => {

        assert.equal(car.park(), 'stopped');
    });
    it('can drive', () => {

        assert.equal(car.drive(), 'vroom');
    })
});*/