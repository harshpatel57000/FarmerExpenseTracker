
package com.farmer.Farm_expense;

import com.farmer.Farm_expense.CropCycle.CropCycle;
import com.farmer.Farm_expense.CropCycle.CropCycleRepository;
import com.farmer.Login_page.User;
import com.farmer.Login_page.UserRepository;
import com.farmer.add_region_page.FarmPage.Farm;
import com.farmer.add_region_page.FarmPage.FarmRepository;
import com.farmer.exception.ErrorException;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Set;

@Service
@Transactional
public class FarmExpenseService {

//--------------------------------------------------------------------------------------//
    private final FarmExpenseRepository farmExpenseRepository;
    private final CropCycleRepository cropCycleRepository;
    private final FarmRepository farmRepository;
    private final UserRepository userRepository;

    public FarmExpenseService(
            FarmExpenseRepository farmExpenseRepository,
            CropCycleRepository cropCycleRepository,
            FarmRepository farmRepository,
            UserRepository userRepository) {
        this.farmExpenseRepository = farmExpenseRepository;
        this.cropCycleRepository = cropCycleRepository;
        this.farmRepository = farmRepository;
        this.userRepository = userRepository;
    }

//--------------------------------------------------------------------------------------//


    // Get the currently logged-in user
    private User getLoggedInUser() {
        Authentication authentication =
                SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null
                || !authentication.isAuthenticated()
                || authentication.getName() == null
                || authentication.getName().equals("anonymousUser")) {
            throw new ErrorException("User is not authenticated");
        }

        return userRepository.findByEmailId(authentication.getName())
                .orElseThrow(() ->
                        new ErrorException("Logged-in user not found"));
    }



    // Verify that the farm belongs to the logged-in user
    private Farm getOwnedFarm(Long farmId) {
        if (farmId == null) {
            throw new ErrorException("Farm ID is required");
        }

        User user = getLoggedInUser();

        return farmRepository
                .findByIdAndUserId(farmId, user.getId())
                .orElseThrow(() ->
                        new ErrorException("Farm not found"));
    }

//--------------------------------------------------------------------------------------//

    // Get all farm IDs belonging to the logged-in user
    private List<Long> getOwnedFarmIds() {
        User user = getLoggedInUser();

        return farmRepository.findAllByUserId(user.getId())
                .stream()
                .map(Farm::getId)
                .toList();
    }

    // Verify an expense belongs to one of the user's farms
    private FarmExpense getOwnedExpense(Long id) {
        List<Long> farmIds = getOwnedFarmIds();

        return farmExpenseRepository
                .findByIdAndFarmIdIn(id, farmIds)
                .orElseThrow(() ->
                        new ErrorException("Farm expense not found"));
    }

    // POST: Add a farm expense
    public FarmExpenseDTO addFarmExpense(FarmExpenseDTO dto) {
        Farm farm = getOwnedFarm(dto.getFarmId());

        FarmExpense entity = FarmExpenseMapper.toEntity(dto);

        // Keep the farm ID consistent with the verified farm
        entity.setFarmId(farm.getId());

        if (dto.getCropCycleId() != null) {
            User user = getLoggedInUser();

            CropCycle cropCycle = cropCycleRepository
                    .findByIdAndFarmUserId(
                            dto.getCropCycleId(), user.getId())
                    .orElseThrow(() ->
                            new ErrorException("Crop cycle not found"));

            if (!cropCycle.getFarm().getId().equals(farm.getId())) {
                throw new ErrorException(
                        "Crop cycle does not belong to this farm");
            }

            entity.setCropCycle(cropCycle);
        } else {
            entity.setCropCycle(null);
        }

        return FarmExpenseMapper.toDTO(
                farmExpenseRepository.save(entity));
    }

    // GET: All expenses belonging to the logged-in user
    @Transactional(readOnly = true)
    public List<FarmExpenseDTO> getAllFarmExpense() {
        List<Long> farmIds = getOwnedFarmIds();

        return farmExpenseRepository.findByFarmIdIn(farmIds)
                .stream()
                .map(FarmExpenseMapper::toDTO)
                .toList();
    }

    // GET: Expense by ID, with ownership verification
    @Transactional(readOnly = true)
    public FarmExpenseDTO getFarmExpenseById(long id) {
        return FarmExpenseMapper.toDTO(getOwnedExpense(id));
    }

    // PUT: Update an existing expense
    public FarmExpenseDTO updateFarmExpense(
            Long id, FarmExpenseDTO dto) {

        FarmExpense entity = getOwnedExpense(id);

        if (dto.getFarmId() != null) {
            Farm farm = getOwnedFarm(dto.getFarmId());
            entity.setFarmId(farm.getId());
        }

        if (dto.getCropCycleId() != null) {
            User user = getLoggedInUser();

            CropCycle cropCycle = cropCycleRepository
                    .findByIdAndFarmUserId(
                            dto.getCropCycleId(), user.getId())
                    .orElseThrow(() ->
                            new ErrorException("Crop cycle not found"));

            if (!cropCycle.getFarm().getId().equals(entity.getFarmId())) {
                throw new ErrorException(
                        "Crop cycle does not belong to this farm");
            }

            entity.setCropCycle(cropCycle);
        } else {
            entity.setCropCycle(null);
        }

        entity.setExpenseType(dto.getExpenseType());
        entity.setExpenseName(dto.getExpenseName());
        entity.setAgroQuantity(dto.getAgroQuantity());
        entity.setTotalAgroExpense(dto.getTotalAgroExpense());
        entity.setNumberOfWorkers(dto.getNumberOfWorkers());
        entity.setPricePerWorker(dto.getPricePerWorker());
        entity.setTotalExpenseOfWorkers(dto.getTotalExpenseOfWorkers());
        entity.setExtraCost(dto.getExtraCost());
        entity.setExpenseDate(dto.getExpenseDate());
        entity.setTotalCost(dto.getTotalCost());

        return FarmExpenseMapper.toDTO(
                farmExpenseRepository.save(entity));
    }

    // PATCH: Update only supplied fields
    public FarmExpenseDTO patchFarmExpense(
            Long id, FarmExpenseDTO dto) {

        FarmExpense entity = getOwnedExpense(id);

        if (dto.getFarmId() != null) {
            Farm farm = getOwnedFarm(dto.getFarmId());
            entity.setFarmId(farm.getId());
        }

        if (dto.getCropCycleId() != null) {
            User user = getLoggedInUser();

            CropCycle cropCycle = cropCycleRepository
                    .findByIdAndFarmUserId(
                            dto.getCropCycleId(), user.getId())
                    .orElseThrow(() ->
                            new ErrorException("Crop cycle not found"));

            if (!cropCycle.getFarm().getId().equals(entity.getFarmId())) {
                throw new ErrorException(
                        "Crop cycle does not belong to this farm");
            }

            entity.setCropCycle(cropCycle);
        }

        if (dto.getExpenseType() != null) {
            entity.setExpenseType(dto.getExpenseType());
        }
        if (dto.getExpenseName() != null) {
            entity.setExpenseName(dto.getExpenseName());
        }
        if (dto.getAgroQuantity() != null) {
            entity.setAgroQuantity(dto.getAgroQuantity());
        }
        if (dto.getTotalAgroExpense() != null) {
            entity.setTotalAgroExpense(dto.getTotalAgroExpense());
        }
        if (dto.getNumberOfWorkers() != null) {
            entity.setNumberOfWorkers(dto.getNumberOfWorkers());
        }
        if (dto.getPricePerWorker() != null) {
            entity.setPricePerWorker(dto.getPricePerWorker());
        }
        if (dto.getTotalExpenseOfWorkers() != null) {
            entity.setTotalExpenseOfWorkers(
                    dto.getTotalExpenseOfWorkers());
        }
        if (dto.getExtraCost() != null) {
            entity.setExtraCost(dto.getExtraCost());
        }
        if (dto.getExpenseDate() != null) {
            entity.setExpenseDate(dto.getExpenseDate());
        }
        if (dto.getTotalCost() != null) {
            entity.setTotalCost(dto.getTotalCost());
        }

        return FarmExpenseMapper.toDTO(
                farmExpenseRepository.save(entity));
    }

    // DELETE: Only delete an expense owned by the logged-in user
    public void deleteFarmExpense(Long id) {
        FarmExpense entity = getOwnedExpense(id);
        farmExpenseRepository.delete(entity);
    }

    // Search expenses by crop name and year, limited to the user's farms
    @Transactional(readOnly = true)
    public Page<FarmExpenseDTO> searchFarmExpenses(
            String cropName,
            int year,
            int page,
            int size,
            String sortBy,
            String direction) {

        if (cropName == null || cropName.isBlank()) {
            throw new IllegalArgumentException(
                    "Crop name is required");
        }

        if (year < 2000 || year > 2100) {
            throw new IllegalArgumentException("Invalid year");
        }

        if (page < 0) {
            throw new IllegalArgumentException(
                    "Page cannot be negative");
        }

        if (size < 1 || size > 100) {
            throw new IllegalArgumentException(
                    "Page size must be between 1 and 100");
        }

        Set<String> allowedSortFields = Set.of(
                "id", "expenseDate", "expenseName", "totalCost");

        if (sortBy == null || !allowedSortFields.contains(sortBy)) {
            sortBy = "expenseDate";
        }

        Sort sort = "asc".equalsIgnoreCase(direction)
                ? Sort.by(sortBy).ascending()
                : Sort.by(sortBy).descending();

        Pageable pageable = PageRequest.of(page, size, sort);

        LocalDate startDate = LocalDate.of(year, 1, 1);
        LocalDate endDate = LocalDate.of(year, 12, 31);

        List<Long> farmIds = getOwnedFarmIds();

        Page<FarmExpense> expensePage =
                farmExpenseRepository
                        .findByFarmIdInAndCropCycle_CropNameIgnoreCaseAndCropCycle_StartDateBetween(
                                farmIds,
                                cropName.trim(),
                                startDate,
                                endDate,
                                pageable);

        return expensePage.map(FarmExpenseMapper::toDTO);
    }
}
