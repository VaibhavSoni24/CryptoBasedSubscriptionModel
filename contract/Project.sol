// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CryptoSubscription {
    address public owner;

    struct Subscription {
        address subscriber;
        uint256 startTime;
        uint256 duration; // in seconds
        bool active;
    }

    mapping(address => Subscription) public subscriptions;
    uint256 public subscriptionFee; // in wei
    uint256 public subscriptionDuration; // in seconds

    event Subscribed(address indexed subscriber, uint256 startTime, uint256 duration);
    event Cancelled(address indexed subscriber);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this.");
        _;
    }

    modifier onlyActiveSubscriber() {
        require(subscriptions[msg.sender].active, "You don't have an active subscription.");
        _;
    }

    constructor(uint256 _feeInWei, uint256 _durationInSeconds) {
        owner = msg.sender;
        subscriptionFee = _feeInWei;
        subscriptionDuration = _durationInSeconds;
    }

    function subscribe() external payable {
        require(msg.value == subscriptionFee, "Incorrect subscription fee.");
        subscriptions[msg.sender] = Subscription(
            msg.sender,
            block.timestamp,
            subscriptionDuration,
            true
        );
        emit Subscribed(msg.sender, block.timestamp, subscriptionDuration);
    }

    function isActive(address user) public view returns (bool) {
        Subscription memory sub = subscriptions[user];
        return sub.active && (block.timestamp <= sub.startTime + sub.duration);
    }

    function cancelSubscription() external onlyActiveSubscriber {
        subscriptions[msg.sender].active = false;
        emit Cancelled(msg.sender);
    }

    function changeSubscriptionFee(uint256 newFee) external onlyOwner {
        subscriptionFee = newFee;
    }

    function changeDuration(uint256 newDuration) external onlyOwner {
        subscriptionDuration = newDuration;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
