package com.farmer.Login_page.UserDTO;

import java.util.List;

public record profileDTO(
    Long id,
    String userName,
    String emailId,
    String phoneNumber,
    List<String> villages
) {

}
