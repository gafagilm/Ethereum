import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';
import web3 from './web3';
import lottery from './lottery';


class App extends Component {
    state = {
        manager: '',
        players: [],
        balance: '',
        value: '',
        message: '',
    };


    async componentDidMount() {
        const manager = await lottery.methods.manager().call();
        const players = await lottery.methods.getPlayers().call();
        const balance = await web3.eth.getBalance(lottery.options.address);
        this.setState({ manager, players, balance });
    };

    onSubmit = async (event) => {
        event.preventDefault();
        const accounts = await web3.eth.getAccounts();

        this.setState({ message: 'waiting' });

        await lottery.methods.enter().send({
            from: accounts[0],
            value: web3.utils.toWei(this.state.value, 'ether')
        });
        this.setState({ message: 'success' });
    };

    onClick = async (event) => {

        const accounts = await web3.eth.getAccounts();

        this.setState({message: 'waiting'});

        await lottery.methods.pickWinner().send({
            from: accounts[0]
        });
        this.setState({ message: 'success' });
    };


    render() {

    return (
        <div>
            <h2>Lottery Contract</h2>
            <p>
                manager: {this.state.manager}.
                players: {this.state.players.length}.
                balance: {web3.utils.fromWei(this.state.balance, 'ether')}.
            </p>
            <hr/>
            <form onSubmit={this.onSubmit}>
                <h4>Want?</h4>
                <div>
                    <label>Amount</label>
                    <input
                        value={this.state.value}
                        onChange={event => this.setState({value: event.target.value})}
                    />
                </div>
                <button>enter</button>
            </form>

            <hr />
            <h4>Ready to pick?</h4>
            <button onClick={this.onClick}>pick</button>

            <hr/>
            <h1>{this.state.message}</h1>
        </div>
    );
};

}

export default App;
