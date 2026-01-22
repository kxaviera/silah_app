// Common data for dropdowns across the app
class AppData {
  static const List<String> countries = [
    'India',
    'UAE',
    'Saudi Arabia',
    'Qatar',
    'Kuwait',
    'Oman',
    'Bahrain',
    'USA',
    'UK',
    'Canada',
    'Australia',
  ];

  static const List<String> religions = [
    'Islam',
    'Christian',
    'Hindu',
    'Sikh',
    'Buddhist',
    'Jain',
    'Other',
  ];

  static const List<String> islamCastes = [
    'Sunni',
    'Shia',
    'Hanafi',
    'Maliki',
    'Shafi',
    'Hanbali',
    'Other',
  ];

  static const List<String> hinduCastes = [
    'Brahmin',
    'Kshatriya',
    'Vaishya',
    'Shudra',
    'Other',
  ];

  static const List<String> christianDenominations = [
    'Catholic',
    'Protestant',
    'Orthodox',
    'Anglican',
    'Other',
  ];

  static const List<String> complexions = [
    'Fair',
    'Wheatish',
    'Medium',
    'Dark',
    'Very Fair',
  ];

  static const List<String> educationLevels = [
    'High School',
    'Diploma',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD',
    'Professional Degree',
  ];

  static const List<String> professions = [
    'Engineer',
    'Doctor',
    'Teacher',
    'Business',
    'IT Professional',
    'Lawyer',
    'Accountant',
    'Government Employee',
    'Student',
    'Other',
  ];

  // Family member occupations
  static const List<String> familyOccupations = [
    'Lawyer',
    'Doctor',
    'Businessman',
    'Businesswoman',
    'Retired',
    'Engineer',
    'Teacher',
    'Government Employee',
    'Private Employee',
    'Self Employed',
    'Farmer',
    'Not Working',
    'Other',
  ];

  // Sibling count options
  static const List<String> siblingCounts = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    'More than 5',
  ];

  // Marital status options
  static const List<String> maritalStatus = [
    'Married',
    'Unmarried',
    'Both',
  ];

  static const List<String> indianStates = [
    'Maharashtra',
    'Delhi',
    'Karnataka',
    'Tamil Nadu',
    'West Bengal',
    'Gujarat',
    'Rajasthan',
    'Uttar Pradesh',
    'Punjab',
    'Kerala',
    'Andhra Pradesh',
    'Telangana',
    'Bihar',
    'Madhya Pradesh',
    'Haryana',
    'Odisha',
    'Jammu and Kashmir',
    'Assam',
    'Jharkhand',
    'Chhattisgarh',
  ];

  static List<String> getCitiesForState(String? state) {
    if (state == null) return [];
    switch (state) {
      case 'Maharashtra':
        return ['Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad', 'Solapur', 'Amravati', 'Kolhapur', 'Sangli', 'Satara', 'Jalgaon', 'Akola', 'Latur', 'Ahmednagar', 'Chandrapur', 'Parbhani', 'Ichalkaranji', 'Jalna', 'Bhusawal', 'Panvel', 'Badlapur', 'Beed', 'Yavatmal', 'Kamptee', 'Gondia', 'Barshi', 'Achalpur', 'Osmanabad', 'Nanded-Waghala', 'Sindhudurg', 'Ratnagiri', 'Wardha', 'Udgir', 'Hinganghat'];
      case 'Delhi':
        return ['New Delhi', 'Delhi', 'North Delhi', 'South Delhi', 'East Delhi', 'West Delhi', 'Central Delhi', 'New Delhi', 'Dwarka', 'Rohini', 'Pitampura', 'Janakpuri', 'Laxmi Nagar', 'Karol Bagh', 'Connaught Place'];
      case 'Karnataka':
        return ['Bangalore', 'Mysore', 'Hubli', 'Mangalore', 'Belagavi', 'Gulbarga', 'Davangere', 'Bellary', 'Bijapur', 'Shimoga', 'Tumkur', 'Raichur', 'Bidar', 'Hospet', 'Hassan', 'Mandya', 'Chitradurga', 'Kolar', 'Gadag', 'Chikmagalur', 'Bagalkot', 'Dharwad', 'Udupi', 'Chamarajanagar', 'Koppal', 'Haveri', 'Yadgir', 'Kodagu', 'Chikkaballapur', 'Ramanagara'];
      case 'Tamil Nadu':
        return ['Chennai', 'Coimbatore', 'Madurai', 'Salem', 'Tiruchirappalli', 'Tirunelveli', 'Erode', 'Vellore', 'Dindigul', 'Thanjavur', 'Tuticorin', 'Kanchipuram', 'Nagercoil', 'Karur', 'Hosur', 'Tiruppur', 'Sivakasi', 'Ranipet', 'Pollachi', 'Rajapalayam', 'Pudukkottai', 'Neyveli', 'Nagapattinam', 'Kumbakonam', 'Gudiyatham', 'Dharmapuri', 'Cuddalore', 'Bhavani', 'Arakkonam', 'Arani'];
      case 'West Bengal':
        return ['Kolkata', 'Howrah', 'Durgapur', 'Asansol', 'Siliguri', 'Bardhaman', 'Malda', 'Kharagpur', 'Haldia', 'Habra', 'Krishnanagar', 'Jalpaiguri', 'Raiganj', 'Medinipur', 'Baharampur', 'Chinsurah', 'Balurghat', 'Bankura', 'Darjeeling', 'Alipurduar', 'Purulia', 'Jangipur', 'Bangaon', 'Cooch Behar', 'Kalyani', 'Katwa', 'Santipur', 'Bishnupur', 'Uluberia', 'Serampore'];
      case 'Gujarat':
        return ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar', 'Jamnagar', 'Gandhinagar', 'Junagadh', 'Gandhidham', 'Anand', 'Navsari', 'Morvi', 'Nadiad', 'Surendranagar', 'Bharuch', 'Mehsana', 'Bhuj', 'Porbandar', 'Palanpur', 'Valsad', 'Vapi', 'Gondal', 'Veraval', 'Godhra', 'Patan', 'Botad', 'Sidhpur', 'Dhoraji', 'Wadhwan', 'Dahod'];
      case 'Rajasthan':
        return ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Bikaner', 'Ajmer', 'Bhilwara', 'Alwar', 'Bharatpur', 'Banswara', 'Sikar', 'Pali', 'Hanumangarh', 'Beawar', 'Kishangarh', 'Churu', 'Ganganagar', 'Baran', 'Chittorgarh', 'Jhunjhunu', 'Bundi', 'Baran', 'Dausa', 'Jhalawar', 'Karauli', 'Nagaur', 'Pratapgarh', 'Rajsamand', 'Sawai Madhopur', 'Tonk'];
      case 'Uttar Pradesh':
        return ['Lucknow', 'Kanpur', 'Agra', 'Varanasi', 'Meerut', 'Allahabad', 'Bareilly', 'Gorakhpur', 'Aligarh', 'Moradabad', 'Saharanpur', 'Ghaziabad', 'Noida', 'Firozabad', 'Jhansi', 'Muzaffarnagar', 'Mathura', 'Rampur', 'Shahjahanpur', 'Farrukhabad', 'Fatehpur', 'Budaun', 'Sitapur', 'Hapur', 'Unnao', 'Faizabad', 'Bahraich', 'Mirzapur', 'Sambhal', 'Hardoi'];
      case 'Punjab':
        return ['Chandigarh', 'Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala', 'Bathinda', 'Hoshiarpur', 'Pathankot', 'Moga', 'Abohar', 'Malerkotla', 'Khanna', 'Mohali', 'Barnala', 'Firozpur', 'Phagwara', 'Rajpura', 'Sangrur', 'Nawanshahr', 'Faridkot', 'Rupnagar', 'Fazilka', 'Gurdaspur', 'Kot Kapura', 'Muktsar', 'Batala', 'Mansa', 'Malout', 'Nakodar', 'Zira'];
      case 'Kerala':
        return ['Kochi', 'Thiruvananthapuram', 'Kozhikode', 'Thrissur', 'Kollam', 'Alappuzha', 'Kannur', 'Kottayam', 'Palakkad', 'Malappuram', 'Manjeri', 'Thalassery', 'Ponnani', 'Vatakara', 'Kanhangad', 'Koyilandy', 'Neyyattinkara', 'Kayamkulam', 'Nedumangad', 'Kattappana', 'Changanassery', 'Kothamangalam', 'Kodungallur', 'Perumbavoor', 'Muvattupuzha', 'Chalakudy', 'Kunnamkulam', 'Shoranur', 'Pala', 'Thodupuzha'];
      case 'Andhra Pradesh':
        return ['Hyderabad', 'Visakhapatnam', 'Vijayawada', 'Guntur', 'Nellore', 'Kurnool', 'Rajahmundry', 'Kakinada', 'Tirupati', 'Kadapa', 'Anantapur', 'Eluru', 'Ongole', 'Nandyal', 'Machilipatnam', 'Tenali', 'Chittoor', 'Hindupur', 'Proddatur', 'Bhimavaram', 'Adoni', 'Madanapalle', 'Guntakal', 'Dharmavaram', 'Gudivada', 'Srikakulam', 'Narasaraopet', 'Tadepalligudem', 'Chilakaluripet', 'Ponnur'];
      case 'Telangana':
        return ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar', 'Ramagundam', 'Khammam', 'Mahbubnagar', 'Mancherial', 'Adilabad', 'Nalgonda', 'Siddipet', 'Suryapet', 'Miryalaguda', 'Jagtial', 'Kamareddy', 'Sangareddy', 'Bodhan', 'Medak', 'Narayanpet', 'Gadwal', 'Wanaparthy', 'Nagarkurnool', 'Vikarabad', 'Jangaon', 'Bhongir', 'Yadadri', 'Siddipet', 'Zaheerabad', 'Narayankhed'];
      case 'Bihar':
        return ['Patna', 'Gaya', 'Bhagalpur', 'Muzaffarpur', 'Darbhanga', 'Arrah', 'Begusarai', 'Katihar', 'Munger', 'Chhapra', 'Danapur', 'Bettiah', 'Saharsa', 'Hajipur', 'Sasaram', 'Dehri', 'Bihar Sharif', 'Motihari', 'Nawada', 'Bagaha', 'Kishanganj', 'Jamalpur', 'Buxar', 'Jehanabad', 'Aurangabad', 'Lakhisarai', 'Sitamarhi', 'Madhepura', 'Samastipur', 'Siwan'];
      case 'Madhya Pradesh':
        return ['Indore', 'Bhopal', 'Gwalior', 'Jabalpur', 'Ujjain', 'Sagar', 'Ratlam', 'Satna', 'Burhanpur', 'Murwara', 'Singrauli', 'Rewa', 'Chhindwara', 'Khandwa', 'Dewas', 'Mandsaur', 'Neemuch', 'Pithampur', 'Morena', 'Bhind', 'Guna', 'Shivpuri', 'Vidisha', 'Chhatarpur', 'Damoh', 'Khargone', 'Barwani', 'Alirajpur', 'Jhabua', 'Dhar'];
      case 'Haryana':
        return ['Faridabad', 'Gurgaon', 'Panipat', 'Ambala', 'Yamunanagar', 'Rohtak', 'Hisar', 'Karnal', 'Sonipat', 'Panchkula', 'Bhiwani', 'Sirsa', 'Bahadurgarh', 'Jind', 'Kaithal', 'Palwal', 'Rewari', 'Hansi', 'Narnaul', 'Fatehabad', 'Tohana', 'Narwana', 'Mandi Dabwali', 'Charkhi Dadri', 'Shahbad', 'Pehowa', 'Samalkha', 'Pinjore', 'Rania', 'Ladwa'];
      case 'Odisha':
        return ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Berhampur', 'Sambalpur', 'Puri', 'Baleshwar', 'Baripada', 'Bhadrak', 'Balangir', 'Jharsuguda', 'Bargarh', 'Rayagada', 'Jeypore', 'Bhawanipatna', 'Dhenkanal', 'Barbil', 'Kendujhar', 'Paradip', 'Talcher', 'Angul', 'Kendrapara', 'Jagatsinghpur', 'Puri', 'Nayagarh', 'Khordha', 'Ganjam', 'Gajapati', 'Koraput', 'Malkangiri'];
      case 'Jammu and Kashmir':
        return ['Srinagar', 'Jammu', 'Anantnag', 'Baramulla', 'Sopore', 'Kathua', 'Udhampur', 'Poonch', 'Rajouri', 'Kupwara', 'Bandipora', 'Ganderbal', 'Pulwama', 'Shopian', 'Kulgam', 'Doda', 'Ramban', 'Reasi', 'Samba', 'Kishtwar'];
      case 'Assam':
        return ['Guwahati', 'Silchar', 'Dibrugarh', 'Jorhat', 'Nagaon', 'Tinsukia', 'Tezpur', 'Bongaigaon', 'Dhubri', 'Goalpara', 'Barpeta', 'Karimganj', 'Sivasagar', 'Golaghat', 'Lakhimpur', 'Dhemaji', 'Morigaon', 'Hailakandi', 'Kokrajhar', 'Cachar'];
      case 'Jharkhand':
        return ['Jamshedpur', 'Dhanbad', 'Ranchi', 'Bokaro Steel City', 'Hazaribagh', 'Deoghar', 'Giridih', 'Ramgarh', 'Medininagar', 'Chirkunda', 'Chaibasa', 'Gumla', 'Lohardaga', 'Pakur', 'Simdega', 'Khunti', 'Latehar', 'Sahibganj', 'Godda', 'Dumka'];
      case 'Chhattisgarh':
        return ['Raipur', 'Bhilai', 'Korba', 'Bilaspur', 'Durg', 'Rajnandgaon', 'Raigarh', 'Jagdalpur', 'Ambikapur', 'Dhamtari', 'Chirmiri', 'Mahasamund', 'Kanker', 'Kawardha', 'Janjgir', 'Korba', 'Dantewada', 'Bijapur', 'Narayanpur', 'Sukma'];
      default:
        return ['Select state first'];
    }
  }

  static List<String> getCastesForReligion(String? religion) {
    if (religion == null) return [];
    switch (religion.toLowerCase()) {
      case 'islam':
        return islamCastes;
      case 'hindu':
        return hinduCastes;
      case 'christian':
        return christianDenominations;
      default:
        return ['Other'];
    }
  }
}
