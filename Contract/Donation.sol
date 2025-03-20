// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DirectDonation {
    address public owner;

    struct Beneficiary {
        string name;
        address payable wallet;
        uint256 totalReceived;
    }

    mapping(address => Beneficiary) public beneficiaries;
    mapping(address => bool) public isBeneficiary;

    event DonationReceived(address indexed donor, address indexed beneficiary, uint256 amount);
    event BeneficiaryAdded(address indexed wallet, string name);
    event BeneficiaryRemoved(address indexed wallet);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addBeneficiary(address payable _wallet, string memory _name) public onlyOwner {
        require(!isBeneficiary[_wallet], "Beneficiary already exists");
        beneficiaries[_wallet] = Beneficiary(_name, _wallet, 0);
        isBeneficiary[_wallet] = true;
        emit BeneficiaryAdded(_wallet, _name);
    }

    function removeBeneficiary(address _wallet) public onlyOwner {
        require(isBeneficiary[_wallet], "Beneficiary does not exist");
        delete beneficiaries[_wallet];
        isBeneficiary[_wallet] = false;
        emit BeneficiaryRemoved(_wallet);
    }

    function donate(address _beneficiary) public payable {
        require(isBeneficiary[_beneficiary], "Invalid beneficiary");
        require(msg.value > 0, "Donation must be greater than zero");

        beneficiaries[_beneficiary].totalReceived += msg.value;
        payable(_beneficiary).transfer(msg.value);

        emit DonationReceived(msg.sender, _beneficiary, msg.value);
    }

    function getBeneficiaryDetails(address _wallet) public view returns (string memory, address, uint256) {
        require(isBeneficiary[_wallet], "Beneficiary does not exist");
        Beneficiary memory beneficiary = beneficiaries[_wallet];
        return (beneficiary.name, beneficiary.wallet, beneficiary.totalReceived);
    }
}

