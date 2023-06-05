// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VRFCoordinatorV2Interface} from "chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract Casino {
    address public bank; // Createur du contrat
    uint256 public constant minBet = 1 ether / 1000; // Mise minimum
    uint256 public constant maxBet = 1 ether; // Mise Maximum
    uint256 public totalBet; // Total des mises
    uint256 public nbrBets; // nombre de mises en cours
    uint256 public maxNbrBets = 50; // nombre maximum de mises
    address[50] public players; // Tableau des joueurs
    uint256 public nbOfPlayers = 0;
    uint256 public constant COM = 5;

    // Joueur
    struct Player {
        uint256 amountBet;
        uint256 numberSelected;
    }

    mapping(address => Player) public playerInfo;

    constructor() {
        bank = msg.sender;
    }

    function balanceOfBank() public view returns (uint256) {
        return address(this).balance;
    }

    function getBalance(address a) public view returns (uint256) {
        return address(a).balance;
    }

    function bet(uint256 _numberSelected) public payable {
        // Conditions
        require(msg.sender != address(0), "adresse non valide");
        require(
            _numberSelected >= 1 && _numberSelected <= 10,
            "Vous devez pariez sur un nombre compris entre 1 et 10 inclus"
        );
        require(
            msg.value >= minBet && msg.value <= maxBet,
            "la mise doit etre comprise entre 1 et 5"
        );

        // on met dans la banque
        //   payable(address(bank)).transfer(msg.value);

        // On enregistre le joueur et sa mise
        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].numberSelected = _numberSelected;

        // On enregistre l'adresse du joueur
        players[nbOfPlayers] = (msg.sender);
        nbOfPlayers++;

        // On met à jour le nombre de mise et la mise total
        nbrBets++;
        totalBet += msg.value;

        if (nbrBets >= maxNbrBets) generateWinnerNumber();
    }

    function generateWinnerNumber() internal {
        // uint256 numberGenerated = ((block.number + block.timestamp) % 10) + 1;
        // distributePrize(uint256(numberGenerated));
        distributePrize(uint256(2));
    }

    function distributePrize(uint256 _numberGenerated) internal {
        address[10] memory winners;
        uint256 count = 0;
        for (uint256 i = 0; i < players.length; ) {
            address playerAddress = players[i];
            if (playerInfo[playerAddress].numberSelected == _numberGenerated) {
                winners[count] = playerAddress;
                count++;
            }
            delete playerInfo[playerAddress];
            i++;
        }

        // Commission de 5%
        uint256 com = (totalBet * COM) / 100;
        totalBet -= com;

        if (count > 0) {
            uint256 winnerEtherAmount = totalBet / count;
            for (uint256 i = 0; i < count; i++) {
                address payable payTo = payable(address(winners[i]));
                if (payTo != address(0)) {
                    payTo.transfer(winnerEtherAmount);
                }
            }
            resetData(true);
        } else {
            resetData(false);
        }
    }

    function resetData(bool isWin) internal {
        for (uint256 i = 0; i < players.length; ) {
            delete players[i];
            i++;
        }
        nbOfPlayers = 0;
        nbrBets = 0;
        if (isWin) {
            totalBet = 0;
        }
    }
}
