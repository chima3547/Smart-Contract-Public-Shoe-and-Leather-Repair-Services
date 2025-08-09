# Smart Contract Public Shoe and Leather Repair Services

A comprehensive blockchain-based system for managing shoe and leather repair services, built on the Stacks blockchain using Clarity smart contracts.

## System Overview

This system consists of five interconnected smart contracts that manage different aspects of public shoe and leather repair services:

### 1. Cobbler Licensing Contract (`cobbler-licensing.clar`)
- Issues and manages permits for shoe repair services
- Tracks cobbler certifications and license renewals
- Handles license suspension and revocation
- Maintains cobbler skill ratings and specializations

### 2. Leather Working Certification Contract (`leather-certification.clar`)
- Manages licenses for custom leather goods and repair services
- Tracks leather working skill levels and certifications
- Handles certification renewals and upgrades
- Maintains records of specialized leather working techniques

### 3. Equipment Maintenance Contract (`equipment-maintenance.clar`)
- Tracks maintenance schedules for shoe repair machinery
- Records equipment inspections and repairs
- Manages equipment certification and safety compliance
- Handles equipment replacement and upgrade tracking

### 4. Material Quality Standards Contract (`material-standards.clar`)
- Ensures leather and shoe repair materials meet quality requirements
- Manages supplier certifications and material testing
- Tracks material batch quality and compliance
- Handles quality violations and corrective actions

### 5. Specialty Service Coordination Contract (`specialty-services.clar`)
- Manages services for orthopedic shoes and custom footwear
- Coordinates specialized repair requests
- Tracks custom order progress and completion
- Handles specialty service pricing and scheduling

## Key Features

- **Decentralized Licensing**: Transparent and immutable licensing system
- **Quality Assurance**: Blockchain-verified material and service standards
- **Equipment Tracking**: Comprehensive maintenance and safety records
- **Specialty Services**: Advanced coordination for custom and medical footwear
- **Audit Trail**: Complete history of all transactions and certifications

## Contract Architecture

Each contract operates independently while maintaining data integrity across the system. The contracts use native Clarity data types and functions for optimal performance and security.

### Data Types Used
- `uint`: For IDs, ratings, timestamps, and quantities
- `principal`: For user and service provider addresses
- `(string-ascii 50)`: For names, descriptions, and short text
- `bool`: For status flags and boolean conditions
- `(optional ...)`: For nullable fields
- `(response ...)`: For function return values with error handling

### Error Handling
All contracts implement comprehensive error handling with descriptive error codes:
- `ERR-NOT-AUTHORIZED` (u100): Unauthorized access attempts
- `ERR-INVALID-INPUT` (u101): Invalid input parameters
- `ERR-NOT-FOUND` (u102): Resource not found
- `ERR-ALREADY-EXISTS` (u103): Duplicate resource creation
- `ERR-EXPIRED` (u104): Expired licenses or certifications

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm for testing
- Basic understanding of Clarity smart contracts

### Installation
1. Clone the repository
2. Install dependencies: `npm install`
3. Run tests: `npm test`
4. Deploy contracts: `clarinet deploy`

### Testing
The system includes comprehensive tests using Vitest:
- Unit tests for each contract function
- Integration tests for cross-contract workflows
- Edge case testing for error conditions
- Performance tests for gas optimization

## Usage Examples

### Issuing a Cobbler License
\`\`\`clarity
(contract-call? .cobbler-licensing issue-license "John's Shoe Repair" u5)
\`\`\`

### Recording Equipment Maintenance
\`\`\`clarity
(contract-call? .equipment-maintenance record-maintenance u1 "Replaced worn belts")
\`\`\`

### Certifying Material Quality
\`\`\`clarity
(contract-call? .material-standards certify-material "Premium Leather Batch #123" u9)
\`\`\`

## Security Considerations

- All contracts implement proper authorization checks
- Input validation prevents malicious data entry
- State changes are atomic and reversible through error handling
- No external dependencies reduce attack surface

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
