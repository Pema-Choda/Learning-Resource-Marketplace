// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearningResourceMarketplace {
    struct Resource {
        uint256 id;
        address seller;
        string title;
        string description;
        string url;
        uint256 price;
        bool isSold;
    }

    uint256 public nextResourceId;
    mapping(uint256 => Resource) public resources;
    mapping(address => uint256[]) public sellerResources;

    event ResourceListed(uint256 indexed resourceId, address indexed seller, string title, uint256 price);
    event ResourcePurchased(uint256 indexed resourceId, address indexed buyer);
    event FundsWithdrawn(address indexed seller, uint256 amount);

    function listResource(string memory _title, string memory _description, string memory _url, uint256 _price) public {
        require(_price > 0, "Price must be greater than zero");
        resources[nextResourceId] = Resource({
            id: nextResourceId,
            seller: msg.sender,
            title: _title,
            description: _description,
            url: _url,
            price: _price,
            isSold: false
        });
        sellerResources[msg.sender].push(nextResourceId);
        emit ResourceListed(nextResourceId, msg.sender, _title, _price);
        nextResourceId++;
    }

    function purchaseResource(uint256 _resourceId) public payable {
        Resource storage resource = resources[_resourceId];
        require(resource.id == _resourceId, "Resource does not exist");
        require(!resource.isSold, "Resource already sold");
        require(msg.value == resource.price, "Incorrect price sent");

        resource.isSold = true;
        payable(resource.seller).transfer(msg.value);

        emit ResourcePurchased(_resourceId, msg.sender);
    }

    function withdrawFunds() public {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(msg.sender).transfer(balance);
        emit FundsWithdrawn(msg.sender, balance);
    }

    function getResource(uint256 _resourceId) public view returns (address, string memory, string memory, string memory, uint256, bool) {
        Resource storage resource = resources[_resourceId];
        return (
            resource.seller,
            resource.title,
            resource.description,
            resource.url,
            resource.price,
            resource.isSold
        );
    }

    function getSellerResources(address _seller) public view returns (uint256[] memory) {
        return sellerResources[_seller];
    }
}
