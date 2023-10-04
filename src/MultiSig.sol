// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract MultiSig {
    error MultiSig__owners_required();
    error MultiSig__invalid_number_of_owners(uint256 required, uint256 actual);
    error MultiSig__invalid_owner(address owner);
    error MultiSig_owner_not_unique(address owner);
    error MultiSig__invalid_tx_id(uint256 txId);
    error MultiSig__tx_already_executed(uint256 txId);
    error MultiSig__tx_already_approved(uint256 txId, address sender);
    error MultiSig__invalid_number_of_approvals(uint256 required, uint256 actual);
    error MultiSig__tx_execution_failed(uint256 txId);
    error MultiSig__tx_not_approved(uint256 txId, address sender);

    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event Submit(uint256 indexed txId);
    event Approve(address indexed owner, uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed txId);
    event Execute(uint256 indexed txId);

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public numConfirmationsRequired;

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public approved;

    modifier onlyOwner() {
        if (!isOwner[msg.sender]) {
            revert MultiSig__invalid_owner(msg.sender);
        }
        _;
    }

    modifier txExists(uint256 txId) {
        if (txId >= transactions.length || transactions[txId].to == address(0)) {
            revert MultiSig__invalid_tx_id(txId);
        }
        _;
    }

    modifier notExecuted(uint256 txId) {
        if (transactions[txId].executed) {
            revert MultiSig__tx_already_executed(txId);
        }
        _;
    }

    modifier notApproved(uint256 txId) {
        if (approved[txId][msg.sender]) {
            revert MultiSig__tx_already_approved(txId, msg.sender);
        }
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        if (_owners.length == 0) {
            revert MultiSig__owners_required();
        }
        if (_required == 0 || _required > _owners.length) {
            revert MultiSig__invalid_number_of_owners(_required, _owners.length);
        }

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            if (owner == address(0)) {
                revert MultiSig__invalid_owner(owner);
            }
            if (isOwner[owner]) {
                revert MultiSig_owner_not_unique(owner);
            }
            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _required;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submit(address _to, uint256 _value, bytes calldata _data) external onlyOwner {
        transactions.push(Transaction({to: _to, value: _value, data: _data, executed: false}));
        emit Submit(transactions.length - 1);
    }

    function approve(uint256 _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId) {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function _getApprovalCount(uint256 _txId) private view returns (uint256 count) {
        for (uint256 i = 0; i < owners.length; i++) {
            if (approved[_txId][owners[i]]) {
                count += 1;
            }
        }
    }

    function execute(uint256 _txId) external txExists(_txId) notExecuted(_txId) {
        if (_getApprovalCount(_txId) < numConfirmationsRequired) {
            revert MultiSig__invalid_number_of_approvals(numConfirmationsRequired, _getApprovalCount(_txId));
        }
        Transaction storage transaction = transactions[_txId];
        transaction.executed = true;
        (bool success,) = transaction.to.call{value: transaction.value}(transaction.data);
        if (!success) {
            revert MultiSig__tx_execution_failed(_txId);
        }
    }

    function revoke(uint256 _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
        if (!approved[_txId][msg.sender]) {
            revert MultiSig__tx_not_approved(_txId, msg.sender);
        }

        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }
}
