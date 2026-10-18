package com.farmer.Agro_ExpenseTest;

import com.farmer.Agro_expense.Agro;
import com.farmer.Agro_expense.AgroRepository;
import com.farmer.Agro_expense.enumValue.AgroUnit;
import com.farmer.Agro_expense.enumValue.ValueUnit;
import com.farmer.Login_page.User;
import com.farmer.Login_page.UserRepository;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@DataJpaTest
class AgroRepositoryTest {

    @Autowired
    private AgroRepository agroRepository;

    @Autowired
    private UserRepository userRepository;

    private User createUser() {
    User user = new User();
    user.setUserName("Test Farmer");
    user.setEmailId("farmer@test.com");
    user.setPhoneNumber("9876543210");
    user.setPassword("testPassword123");
    return user;
}

    private Agro createAgro(User user) {
        return Agro.builder()
                .user(user)
                .productName("Fertilizer")
                .quantity(ValueUnit.builder()
                        .value(2.0)
                        .unit(AgroUnit.BAG)
                        .build())
                .measurement(ValueUnit.builder()
                        .value(50.0)
                        .unit(AgroUnit.KG)
                        .build())
                .pricePerUnit(500.0f)
                .totalWeight(ValueUnit.builder()
                        .value(100.0)
                        .unit(AgroUnit.KG)
                        .build())
                .totalAmount(1000.0f)
                .purchaseDate(LocalDate.of(2026, 10, 18))
                .build();
    }

    // 1. Save and find agro expense by ID
    @Test
    void shouldSaveAndFindAgroById() {
        User user = userRepository.save(createUser());

        Agro savedAgro = agroRepository.save(createAgro(user));

        Optional<Agro> result =
                agroRepository.findById(savedAgro.getId());

        assertTrue(result.isPresent());
        assertEquals("Fertilizer", result.get().getProductName());
        assertEquals(1000.0f, result.get().getTotalAmount());
        assertEquals(user.getId(), result.get().getUser().getId());
    }

    // 2. Find all agro expenses
    @Test
    void shouldFindAllAgroExpenses() {
        User user = userRepository.save(createUser());

        agroRepository.save(createAgro(user));

        Agro secondAgro = createAgro(user);
        secondAgro.setProductName("Seeds");
        agroRepository.save(secondAgro);

        List<Agro> result = agroRepository.findAll();

        assertEquals(2, result.size());
    }

    // 3. Return empty when agro expense does not exist
    @Test
    void shouldReturnEmptyWhenAgroDoesNotExist() {
        Optional<Agro> result = agroRepository.findById(999L);

        assertTrue(result.isEmpty());
    }

    // 4. Delete agro expense
    @Test
    void shouldDeleteAgro() {
        User user = userRepository.save(createUser());

        Agro savedAgro = agroRepository.save(createAgro(user));
        Long agroId = savedAgro.getId();

        agroRepository.deleteById(agroId);
        agroRepository.flush();

        assertFalse(agroRepository.findById(agroId).isPresent());
    }
}