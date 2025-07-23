import '../models/job_model.dart';

List<Job> globalJobs = [
  Job(
    id: '1',
    title: 'Senior Product Designer',
    company: 'Tech Innovators Inc.',
    location: 'San Francisco, CA',
    salary: '80k - 100k',
    type: 'Remote',
    description:
        'We are seeking a dynamic Human Resource Recruiter to join our team. The successful candidate will be responsible for attracting, screening, and recruiting various positions within the company. This role requires excellent communication and interpersonal skills, as well as a strong understanding of recruitment processes.',
    responsibilities: [
      'Manage the full recruitment cycle',
      'Develop and implement recruitment strategies',
      'Conduct interviews and assess candidates\' qualifications',
    ],
    aboutCompany:
        'Tech Innovators Inc. is a leading technology company focused on creating innovative solutions for the future. We are committed to fostering a collaborative environment where our employees can thrive and grow. Our mission is to empower individuals and businesses through cutting-edge technology.',
  ),
  Job(
    id: '2',
    title: 'Senior Product Designer',
    company: 'Design Studio Co.',
    location: 'New York, NY',
    salary: '70k - 90k',
    type: 'Full-Time',
    description:
        'Join our creative team as a Senior Product Designer. You will be responsible for creating user-centered designs and innovative solutions.',
    responsibilities: [
      'Create wireframes and prototypes',
      'Collaborate with development team',
      'Conduct user research and testing',
    ],
    aboutCompany:
        'Design Studio Co. is a creative agency specializing in digital experiences and brand identity.',
  ),
  Job(
    id: '3',
    title: 'Senior Product Designer',
    company: 'Innovation Labs',
    location: 'Austin, TX',
    salary: '75k - 95k',
    type: 'Hybrid',
    description:
        'We are looking for a passionate Senior Product Designer to help shape the future of our products.',
    responsibilities: [
      'Design user interfaces',
      'Create design systems',
      'Mentor junior designers',
    ],
    aboutCompany:
        'Innovation Labs focuses on breakthrough technologies and user experience design.',
  ),
];
