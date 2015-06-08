//
//  Strings.m
//  imdSearch
//
//  Created by Huajie Wu on 11-11-14.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "Strings.h"
#import "Util.h"

@implementation Strings

+(NSString*) getResultNoText:(NSInteger) number {
    return [NSString stringWithFormat:@"命中%d篇", number];
}


+(NSString*) getJournal:(NSString*) journal pubDate:(NSString*) pubDate volume:(NSString*) volume  issue:(NSString*) issue pagination:(NSString*) pagination
{
    NSMutableString* journalInfo = [journal mutableCopy];
    if ([volume isEqualToString:@"(null)"]) {
        volume = @"";
    }
    if ([pubDate isEqualToString:@"(null)"]) {
        pubDate = @"";
    }
    if ([issue isEqualToString:@"(null)"]) {
        issue = @"";
    }
    if ([pagination isEqualToString:@"(null)"]) {
        pagination = @"";
    }
    if (pubDate != nil && pubDate.length > 0)
        [journalInfo appendFormat:@".%@", pubDate];
    if (volume != nil && volume.length > 0 )
        [journalInfo appendFormat:@";%@", volume];
    if (issue != nil && issue.length > 0 )
        [journalInfo appendFormat:@"(%@)", issue];
    if (pagination != nil && pagination.length > 0 )
        [journalInfo appendFormat:@":%@", pagination];
    
    return journalInfo;
}


+(NSString*) arrayToString:(NSArray*) array
{
    NSMutableString* mutableStr = [NSMutableString string];
    for (int i = 0; i < [array count]; i++) {
        if(![mutableStr isEqualToString:@""])
            [mutableStr appendString:@" ,"];
        NSString* aStr = [array objectAtIndex:i];
        aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
        [mutableStr appendString:aStr];
    }
    
    return mutableStr;
}


+(BOOL) validEmail:(NSString*) emailString
{
    NSString *regExPattern = @"\\w+([-+.]\\w*)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    
    if (regExMatches == 0) {
        return NO;
    } else
        return YES;
}

+(BOOL)phoneNumberJudge:(NSString*)number
{
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                              initWithPattern:@"^(((13[0-9]{1})|15[0-9]{1}|18[0-9]{1})\\d{8})$"
                                              options:NSRegularExpressionCaseInsensitive
                                              error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:number
                                                                  options:NSMatchingReportProgress
                                                                    range:NSMakeRange(0, number.length)];
    if (numberofMatch == 0) {
        return NO;
    } else
        return YES;
}


+(NSMutableArray*) Departments
{
    NSMutableArray* ds = [[NSMutableArray alloc] init];
    
    
    NSArray* keys = [NSArray arrayWithObjects:DEPARTMENT_CN, DEPARTMENT_EN,DEPARTMENT_KEY,nil];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"麻醉科", @"anesthesiology", @"Anesthesiology", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"烧伤整形外科", @"burn and Plastic Surge", @"BurnAndPlasticSurge", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"心血管外科", @"cardiac surgery", @"CardiacSurgery", nil] forKeys:keys]];
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"心血管内科", @"cardiology", @"Cardiology", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"重症医学科", @"critical care medicine", @"CriticalCareMedicine", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"中西医结合科", @"department of TCM & WM", @"DepartmentOfTcmWm", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"皮肤科", @"dermatology", @"Dermatology", nil] forKeys:keys]];
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"急诊医学科", @"emergency medicine", @"EmergencyMedicine", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"内分泌科", @"endocrinology", @"Endocrinology", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"消化内科", @"gastroenterology", @"Gastroenterology", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"全科医疗科", @"general practice", @"GeneralPractice", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"普通外科", @"general surgery", @"GeneralSurgery", nil] forKeys:keys]];
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"老年科", @"geriatrics", @"Geriatrics", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"妇科", @"gynecology", @"Gynecology", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"血液内科", @"hematology", @"Hematology", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"传染科", @"infectious diseases", @"InfectiousDiseases", nil] forKeys:keys]];
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"医学检验科", @"laboratory", @"Laboratory", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"管理科室", @"medical affair", @"MedicalAffair", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"医学影像科", @"medical imaging department", @"MedicalImagingDepartment", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"民族医学科", @"national medicine", @"NationalMedicine", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"肾脏内科", @"nephrology", @"Nephrology", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"神经内科", @"neurology", @"Neurology", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"神经外科", @"neurosurgery", @"Neurosurgery", nil] forKeys:keys]];
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"临床营养科", @"nutrition department", @"NutritionDepartment", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"产科", @"obstetrics", @"Obstetrics", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"职业病科", @"Occupational Disease", @"OccupationalDisease", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"肿瘤科", @"oncology", @"Oncology", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"眼科", @"ophthalmology", @"Ophthalmology", nil] forKeys:keys]];
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"骨科", @"orthopedics", @"Orthopedics", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"泌尿外科", @"urology", @"Urology", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"耳鼻咽喉科", @"otolaryngology", @"Otolaryngology", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"病理科", @"pathology", @"Pathology", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"儿科", @"pediatrics", @"Pediatrics", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"药剂科", @"pharmacy", @"Pharmacy", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"医疗美容科", @"plastic surgery", @"PlasticSurgery", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"预防保健科", @"prevention and health care", @"PreventionAndHealthCare", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"精神科", @"psychiatry", @"Psychiatry", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"康复医学科", @"rehabilitation", @"Rehabilitation", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"呼吸内科", @"respiratory", @"Respiratory", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"风湿免疫科", @"rheumatology and clinical immunology", @"RheumatologyAndClinicalImmunology", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"运动医学科", @"sports medicine", @"SportsMedicine", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"口腔科", @"stomatology", @"Stomatology", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"胸外科", @"Thoracic surgery", @"ThoracicSurgery", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"中医科", @"traditional Chinese medicine", @"TraditionalChineseMedicine", nil] forKeys:keys]];
    
    [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"其他科室", @"other department", @"OtherDepartment", nil] forKeys:keys]];
    return ds;
}
+(NSString *)dissolutionDevToken:(NSData *)data
{
    NSString *deviceNumber1 = [NSString stringWithFormat:@"%@",data];
    NSString *deviceNumber2 = [deviceNumber1 stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *deviceNumber3 = [deviceNumber2 stringByReplacingOccurrencesOfString:@"<" withString:@""];
    NSString *deviceNumber = [deviceNumber3 stringByReplacingOccurrencesOfString:@">" withString:@""];
    return deviceNumber;
}
+ (BOOL)judgeStringAsc:(NSString *)str
{
    if (str.length == 0) {
        return NO;
    }
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                              initWithPattern:@"^[\\u4E00-\\u9FA5\\uF900-\\uFA2D]+$"
                                              options:NSRegularExpressionCaseInsensitive
                                              error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:str
                                                                  options:NSMatchingReportProgress
                                                                    range:NSMakeRange(0, str.length)];
    if (numberofMatch == 0) {
        return NO;
    } else
        return YES;
}
+(NSMutableDictionary *)getUserInfo:(NSMutableDictionary*)dic
{
  NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
  NSMutableDictionary *doctorInfoDic = [[NSMutableDictionary alloc] init];
  NSMutableDictionary *hospitalDic = [[NSMutableDictionary alloc] init];
  NSMutableDictionary *studentInfoDic = [[NSMutableDictionary alloc] init];
  if ([[dic objectForKey:REGISTER_INFO_USERTYPE] isEqualToString:USERTYPE_STUDENT]) {
    [resultDic setObject:[dic objectForKey:REGISTER_INFO_USERTYPE] forKey:REGISTER_INFO_USERTYPE];
      //[resultDic setObject:[dic objectForKey:REGISTER_INFO_USERNAME] forKey:REGISTER_INFO_USERNAME];
    [resultDic setObject:[dic objectForKey:REGISTER_INFO_REALNAME] forKey:REGISTER_INFO_REALNAME];
    NSString *temp = [dic objectForKey:REGISTER_INFO_USERNAME];
    if (temp.length > 0) {
      [resultDic setObject:[dic objectForKey:REGISTER_INFO_USERNAME] forKey:REGISTER_INFO_EMAIL];
    }
    temp = nil;
    temp = [dic objectForKey:REGISTER_INFO_MOBILE];
    if (temp.length > 0) {
      [resultDic setObject:[dic objectForKey:REGISTER_INFO_MOBILE] forKey:REGISTER_INFO_MOBILE];
    }
    [studentInfoDic setObject:[dic objectForKey:REGISTER_INFO_ADMISSIONYEAR] forKey:REGISTER_INFO_ADMISSIONYEAR];
    [studentInfoDic setObject:[dic objectForKey:REGISTER_INFO_MAJOR] forKey:REGISTER_INFO_MAJOR];
    [studentInfoDic setObject:[dic objectForKey:REGISTER_INFO_DEGREE] forKey:REGISTER_INFO_DEGREE];
    [studentInfoDic setObject:[dic objectForKey:REGISTER_INFO_SCHOOL] forKey:REGISTER_INFO_SCHOOL];
    [studentInfoDic setObject:[dic objectForKey:REGISTER_INFO_STUDENTID] forKey:REGISTER_INFO_STUDENTID];
    [studentInfoDic setObject:[dic objectForKey:REGISTER_INFO_GRADYEAR] forKey:REGISTER_INFO_GRADYEAR];
    [resultDic setObject:studentInfoDic forKey:REGISTER_INFO_studentInfo];
    
    [resultDic setObject:[dic objectForKey:REGISTER_SOURCE] forKey:REGISTER_SOURCE];
    
  }else
  {
    if ([[dic objectForKey:REGISTER_INFO_TITLE] isEqualToString:@"主任医师"]) {
      [dic removeObjectForKey:REGISTER_INFO_TITLE];
      [dic setObject:@"ChiefPhysician" forKey:REGISTER_INFO_TITLE];
    }else if ([[dic objectForKey:REGISTER_INFO_TITLE] isEqualToString:@"副主任医师"])
    {
      [dic removeObjectForKey:REGISTER_INFO_TITLE];
      [dic setObject:@"DeputyChiefPhysician" forKey:REGISTER_INFO_TITLE];
    }else if([[dic objectForKey:REGISTER_INFO_TITLE] isEqualToString:@"主治医师"])
    {
            [dic removeObjectForKey:REGISTER_INFO_TITLE];
            [dic setObject:@"Physician" forKey:REGISTER_INFO_TITLE];
    }else if([[dic objectForKey:REGISTER_INFO_TITLE] isEqualToString:@"医师/医士"])
    {
        [dic removeObjectForKey:REGISTER_INFO_TITLE];
        [dic setObject:@"Healers" forKey:REGISTER_INFO_TITLE];
    }
    [resultDic setObject:[dic objectForKey:REGISTER_INFO_USERTYPE] forKey:REGISTER_INFO_USERTYPE];
    //[resultDic setObject:[dic objectForKey:REGISTER_INFO_USERNAME] forKey:REGISTER_INFO_USERNAME];
    [resultDic setObject:[dic objectForKey:REGISTER_INFO_REALNAME] forKey:REGISTER_INFO_REALNAME];
    NSString *temp = [dic objectForKey:REGISTER_INFO_USERNAME];
    if (temp.length > 0) {
        [resultDic setObject:[dic objectForKey:REGISTER_INFO_USERNAME] forKey:REGISTER_INFO_EMAIL];
    }
    temp = nil;
    temp = [dic objectForKey:REGISTER_INFO_MOBILE];
    if (temp.length > 0) {
        [resultDic setObject:[dic objectForKey:REGISTER_INFO_MOBILE] forKey:REGISTER_INFO_MOBILE];
    }
    [doctorInfoDic setObject:[dic objectForKey:REGISTER_INFO_TITLE] forKey:REGISTER_INFO_TITLE];
    [doctorInfoDic setObject:[dic objectForKey:REGISTER_INFO_DEPARTMENT] forKey:REGISTER_INFO_DEPARTMENT];
    [hospitalDic setObject:[dic objectForKey:REGISTER_INFO_hospitalId] forKey:REGISTER_INFO_hospitalId];
    [hospitalDic setObject:@"System"forKey:REGISTER_INFO_hospitalDataType];
    [doctorInfoDic setObject:hospitalDic forKey:REGISTER_INFO_HospitalRef];
    [resultDic setObject:doctorInfoDic forKey:REGISTER_INFO_DoctorInfo];
    
    [resultDic setObject:[dic objectForKey:REGISTER_SOURCE] forKey:REGISTER_SOURCE];
    
    }    
    
    return resultDic;
}

+ (NSString *)getPosition:(NSString *)str
{
    NSString *position;
    position = @"";
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"主任医师",@"ChiefPhysician",@"副主任医师",@"DeputyChiefPhysician",@"主治医师",@"Physician",@"医师/医士",@"Healers",nil];
    if (str.length >0) {
        position = [[dic objectForKey:str] copy];
        if (position.length <= 0) {
            position = @"";
        }
    }
    
    return position;
}
+ (NSString *)getPositionEN:(NSString *)str
{
    NSString *position;
    position = @"";
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"ChiefPhysician",@"主任医师",@"DeputyChiefPhysician",@"副主任医师",@"Physician",@"主治医师",@"Healers",@"医师/医士",nil];
    if (str.length >0) {
        position = [[dic objectForKey:str] copy];
        if (position.length <= 0) {
            position = @"";
        }
    }
    
    return position;
}

+ (NSString *)getDepartmentString:(NSString *)str
{
    NSString *department;
    department = @"";
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"麻醉科",@"Anesthesiology",@"烧伤整形外科",@"BurnAndPlasticSurge",@"心血管外科",@"CardiacSurgery",@"心血管内科",@"Cardiology",@"重症医学科",@"CriticalCareMedicine",@"中西医结合科",@"DepartmentOfTcmWm",@"皮肤科",@"Dermatology",@"急诊医学科",@"EmergencyMedicine",@"内分泌科",@"Endocrinology",@"消化内科",@"Gastroenterology",@"全科医疗科",@"GeneralPractice",@"普通外科",@"GeneralSurgery",@"老年科",@"Geriatrics",@"妇科",@"Gynecology",@"血液内科",@"Hematology",@"传染科",@"InfectiousDiseases",@"医学检验科",@"Laboratory",@"管理科室",@"MedicalAffair",@"医学影像科",@"MedicalImagingDepartment",@"民族医学科",@"NationalMedicine",@"肾脏内科",@"Nephrology",@"神经内科",@"Neurology",@"神经外科",@"Neurosurgery",@"临床营养科",@"NutritionDepartment",@"产科",@"Obstetrics",@"职业病科",@"Occupational Disease",@"肿瘤科",@"Oncology",@"眼科",@"Ophthalmology",@"骨科",@"Orthopedics",@"泌尿外科",@"Urology",@"耳鼻咽喉科",@"Otolaryngology",@"病理科",@"Pathology",@"儿科",@"Pediatrics",@"药剂科",@"Pharmacy",@"医疗美容科",@"PlasticSurgery",@"预防保健科",@"PreventionAndHealthCare",@"精神科",@"Psychiatry",@"康复医学科",@"Rehabilitation",@"呼吸内科",@"Respiratory",@"风湿免疫科",@"RheumatologyAndClinicalImmunology",@"运动医学科",@"SportsMedicine",@"口腔科",@"Stomatology",@"胸外科",@"ThoracicSurgery",@"中医科",@"TraditionalChineseMedicine",@"其他科室",@"OtherDepartment",nil];
    if (str.length >0) {
        department = [[dic objectForKey:str] copy];
        if (department.length <= 0) {
            department = @"";
        }
    }
    
    return department;
}
+(NSString *)getDegree:(NSString *)str
{
    NSString *degree;
    degree = @"";
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"学士",@"Bachelor",@"硕士",@"Master",@"博士",@"Doctor",nil];
    if (str.length >0) {
        degree = [[dic objectForKey:str] copy];
        if (degree.length <= 0) {
            degree = @"";
        }
    }
    
    return degree;
}
+(NSString *)getDegreeEN:(NSString *)str
{
    NSString *degree;
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"Bachelor",@"学士",@"Master",@"硕士",@"Doctor",@"博士",nil];
    if (str.length >0) {
        degree = [[dic objectForKey:str] copy];
        if (degree.length <= 0) {
            degree = @"";
        }
    }
    
    return degree;
}

+ (NSString *)getIdentity:(NSString *)str{
    NSString *identity = @"";
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"临床医师",@"Doctor",@"医学院学生", @"Student",nil];
    if (str.length >0) {
        identity = [[dic objectForKey:str] copy];
        if (identity.length <= 0) {
            identity = @"";
        }
    }
    
    return identity;
}

+ (NSString *)getIdentityEncode:(NSString *)str{
    NSString *identity = @"";
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"Doctor",@"临床医师",@"Student",@"医学院学生",nil];
    if (str.length >0) {
        identity = [[dic objectForKey:str] copy];
        if (identity.length <= 0) {
            identity = @"";
        }
    }
    
    return identity;
}
@end
