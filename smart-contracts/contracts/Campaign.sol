pragma solidity ^0.4.17;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint256 minimum) public {
        address newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (address[]) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint256 value;
        address recipient;
        bool complete;
        uint256 approvalCount;
        // People who approve the request
        mapping(address => bool) approvals;
    }

    // Storage and Memory references
    // Storage: Store a data permanently on contract (like HDD)
    // Memory: Store a data temporarily on contract (like RAM)

    // Array and Mapping in solidity
    // Array Searching Complexity: Linear Time Searching
    // Mapping Searching Complexity: Constanct Time Searching

    // This is a Storage references
    Request[] public requests;
    address public manager;
    uint256 public minimumContribution;
    uint256 public approversCount;

    // Since Array consume a lot gases, we gonna use mapping (Object) to reduce that cost.
    // address[] public approvers;
    mapping(address => bool) public approvers;

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    function Campaign(uint256 minimum, address creator) public {
        manager = creator;
        minimumContribution = minimum;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution);

        // Using Array
        // approvers.push(msg.sender);

        // Using mapping
        approvers[msg.sender] = true;

        approversCount++;
    }

    function createRequest(
        string description,
        uint256 value,
        address recipient
    ) public restricted {
        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });

        // Struct Declaration Syntax Optional
        // Both of them is the same. But the below one was not specified the field that the value belongs to
        // Request(description, value, recipient, false);

        requests.push(newRequest);
    }

    function approveRequest(uint256 index) public {
        // To refer to the storage solidity variable
        Request storage request = requests[index];

        // Verify that the approver has been donated to the contract
        require(approvers[msg.sender]);
        // Verify that the apporver hasn't been approve to the request.
        require(!request.approvals[msg.sender]);

        // Assign an address of the approver to the approvals list of the request
        request.approvals[msg.sender] = true;
        // Increment the amount of approval
        request.approvalCount++;
    }

    function finalizeRequest(uint256 index) public restricted {
        Request storage request = requests[index];

        // Verify that the approval is greather than a half of the approvers
        require(request.approvalCount > (approversCount / 2));
        // Verify that the request is not completed.
        require(!request.complete);

        request.recipient.transfer(request.value);
        request.complete = true;
    }
}
