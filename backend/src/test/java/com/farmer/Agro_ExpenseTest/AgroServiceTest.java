
package com.farmer.Agro_ExpenseTest;

import com.farmer.Agro_expense.Agro;
import com.farmer.Agro_expense.AgroDTO;
import com.farmer.Agro_expense.AgroRepository;
import com.farmer.Agro_expense.AgroService;
import com.farmer.Agro_expense.ValueUnitDTO;
import com.farmer.Agro_expense.enumValue.AgroUnit;
import com.farmer.Agro_expense.enumValue.ValueUnit;
import com.farmer.Login_page.User;
import com.farmer.Login_page.UserRepository;
import com.farmer.exception.ErrorException;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AgroServiceTest {

    @Mock
    private AgroRepository agroRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private AgroService agroService;

    private User createUser() {
        User user = new User();
        user.setId(1L);
        return user;
    }

    private Agro createAgro(User user) {
        return Agro.builder()
                .id(10L)
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

    private AgroDTO createDTO() {
        return AgroDTO.builder()
                .userId(1L)
                .productName("Fertilizer")
                .quantity(ValueUnitDTO.builder()
                        .value(2.0)
                        .unit(AgroUnit.BAG)
                        .build())
                .measurement(ValueUnitDTO.builder()
                        .value(50.0)
                        .unit(AgroUnit.KG)
                        .build())
                .pricePerUnit(500.0f)
                .purchaseDate(LocalDate.of(2026, 10, 18))
                .build();
    }

    // 1. Add agro expense and calculate totals
    @Test
    void shouldAddAgroAndCalculateTotals() {
        User user = createUser();
        AgroDTO dto = createDTO();

        when(userRepository.findById(1L))
                .thenReturn(Optional.of(user));

        when(agroRepository.save(any(Agro.class)))
                .thenAnswer(invocation -> {
                    Agro agro = invocation.getArgument(0);
                    agro.setId(10L);
                    return agro;
                });

        AgroDTO result = agroService.addAgro(dto);

        assertEquals(10L, result.getId());
        assertEquals("Fertilizer", result.getProductName());
        assertEquals(100.0, result.getTotalWeight().getValue());
        assertEquals(AgroUnit.KG, result.getTotalWeight().getUnit());
        assertEquals(1000.0f, result.getTotalAmount());

        verify(userRepository).findById(1L);
        verify(agroRepository).save(any(Agro.class));
    }

    // 2. User does not exist
    @Test
    void shouldThrowExceptionWhenUserDoesNotExist() {
        AgroDTO dto = createDTO();

        when(userRepository.findById(1L))
                .thenReturn(Optional.empty());

        assertThrows(
                ErrorException.class,
                () -> agroService.addAgro(dto)
        );

        verify(agroRepository, never()).save(any(Agro.class));
    }

    // 3. Get all agro expenses
    @Test
    void shouldReturnAllAgroExpenses() {
        User user = createUser();

        Agro agro1 = createAgro(user);
        Agro agro2 = createAgro(user);
        agro2.setId(11L);
        agro2.setProductName("Seeds");

        when(agroRepository.findAll())
                .thenReturn(List.of(agro1, agro2));

        List<AgroDTO> result = agroService.getAllAgro();

        assertEquals(2, result.size());
        assertEquals("Fertilizer", result.get(0).getProductName());
        assertEquals("Seeds", result.get(1).getProductName());
    }

    // 4. Get agro expense by ID
    @Test
    void shouldReturnAgroById() {
        User user = createUser();
        Agro agro = createAgro(user);

        when(agroRepository.findById(10L))
                .thenReturn(Optional.of(agro));

        AgroDTO result = agroService.getAgroById(10L);

        assertEquals(10L, result.getId());
        assertEquals("Fertilizer", result.getProductName());
        assertEquals(1L, result.getUserId());
    }

    // 5. Agro expense does not exist
    @Test
    void shouldThrowExceptionWhenAgroDoesNotExist() {
        when(agroRepository.findById(99L))
                .thenReturn(Optional.empty());

        assertThrows(
                ErrorException.class,
                () -> agroService.getAgroById(99L)
        );
    }

    // 6. PUT updates agro expense
    @Test
    void shouldUpdateAgroUsingPut() {
        User user = createUser();
        Agro agro = createAgro(user);

        AgroDTO dto = createDTO();
        dto.setProductName("New Fertilizer");
        dto.setQuantity(ValueUnitDTO.builder()
                .value(3.0)
                .unit(AgroUnit.BAG)
                .build());

        when(agroRepository.findById(10L))
                .thenReturn(Optional.of(agro));

        when(agroRepository.save(any(Agro.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        AgroDTO result = agroService.putAgro(10L, dto);

        assertEquals("New Fertilizer", result.getProductName());
        assertEquals(3.0, result.getQuantity().getValue());
        assertEquals(150.0, result.getTotalWeight().getValue());
        assertEquals(1500.0f, result.getTotalAmount());

        verify(agroRepository).save(any(Agro.class));
    }

    // 7. PATCH updates only supplied fields
    @Test
    void shouldPatchOnlyProvidedFields() {
        User user = createUser();
        Agro agro = createAgro(user);

        AgroDTO dto = AgroDTO.builder()
                .productName("Updated Fertilizer")
                .build();

        when(agroRepository.findById(10L))
                .thenReturn(Optional.of(agro));

        when(agroRepository.save(any(Agro.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        AgroDTO result = agroService.patchAgro(10L, dto);

        assertEquals("Updated Fertilizer", result.getProductName());
        assertEquals(2.0, result.getQuantity().getValue());
        assertEquals(1000.0f, result.getTotalAmount());
    }

    // 8. PATCH fails if agro expense does not exist
    @Test
    void shouldThrowExceptionWhenPatchingMissingAgro() {
        when(agroRepository.findById(99L))
                .thenReturn(Optional.empty());

        AgroDTO dto = AgroDTO.builder()
                .productName("Updated Fertilizer")
                .build();

        assertThrows(
                ErrorException.class,
                () -> agroService.patchAgro(99L, dto)
        );

        verify(agroRepository, never()).save(any(Agro.class));
    }

    // 9. PUT fails if agro expense does not exist
    @Test
    void shouldThrowExceptionWhenUpdatingMissingAgro() {
        when(agroRepository.findById(99L))
                .thenReturn(Optional.empty());

        AgroDTO dto = createDTO();

        assertThrows(
                ErrorException.class,
                () -> agroService.putAgro(99L, dto)
        );

        verify(agroRepository, never()).save(any(Agro.class));
    }

    // 10. Delete agro expense
    @Test
    void shouldDeleteAgro() {
        agroService.deleteAgro(10L);

        verify(agroRepository).deleteById(10L);
    }
}
